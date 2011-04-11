class ResourceImporter < ActiveRecord::Base

  IMPORT_STATUS_COMPLETED = 'completed'
  IMPORT_STATUS_INCOMPLETE = 'incomplete'
  IMPORT_STATUS_PARTIALLY_COMPLETED = 'partially completed'
  IMPORT_STATUS_ERROR = 'completely failure'

  serialize :failure_items_inspection
  serialize :imported_item_ids

  def completed?; self.import_status == IMPORT_STATUS_COMPLETED; end
  def incomplete?; self.import_status == IMPORT_STATUS_INCOMPLETE; end
  def error?; self.import_status == IMPORT_STATUS_ERROR; end
  def partially_completed?; self.import_status == IMPORT_STATUS_PARTIALLY_COMPLETED; end

  attr_accessor :data
  cattr_accessor :per_page
  @@per_page = 20

  belongs_to :topic
  belongs_to :user

  #
  # Parse and process user uploaded YAML file, read items from each row and
  # create or log (in case failure) object
  #
  def import
    begin
      # Parse as YAML
      document = YAML.load(data.read)

      # Scan raw by raw
      items = document[model.to_s.pluralize.downcase]

      if items && !items.empty?
        # If raw data is valid
        items.each{|item| import_item(item)}

        # Determine import status
        if completed?
          self.import_status = IMPORT_STATUS_INCOMPLETE if self.failure_items.to_i > 0
        end
      else
        return false
      end
    rescue => e
      logger.error(e)
      self.error = e.inspect
      self.import_status = IMPORT_STATUS_ERROR

      raise e if defined?(RAILS_ENV) && ['development', 'test'].include?(RAILS_ENV.to_s.downcase)
    end

    save
  end

  def import_item(item)
    object = build_object(item)
    if !object.save
      another_failure(object)
      if !partially_completed?
        self.import_status = IMPORT_STATUS_PARTIALLY_COMPLETED
      end
    else
      another_success(object)
      if !partially_completed?
        self.import_status = IMPORT_STATUS_COMPLETED
      end
    end
  end

  def another_success(object)
    self.imported_items ||= 0
    self.imported_items += 1
    self.imported_item_ids ||= []
    self.imported_item_ids << object.id 
  end

  def another_failure(object)
    self.failure_items ||= 0
    self.failure_items += 1
    self.failure_items_inspection ||= []
    self.failure_items_inspection << [object.errors, object.attributes]
  end

  def build_object(item)
    model_attributes = process_target_attributes(item)
    r = Restaurant.new model_attributes

    r.topic_id = self.topic_id if !model_attributes.include?(:topic_id)
    r
  end

  def process_target_attributes(item)
    item.inject({}) {|hash, value| hash[value.first] = value.last; hash}
  end

  def process_value_by_name(column_name, value)
#    case column_name
#      when /_array$/
#        value.collect{|v| v}
#      when /_map$/
#        value.inject({}) {|map, v| map[v.first.value] = v.last.value; map}
#      else
#        value
#    end
    value
  end

  def total_items
    self.imported_items.to_i + self.failure_items.to_i
  end

end
