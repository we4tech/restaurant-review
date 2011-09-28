class FormAttribute < ActiveRecord::Base

  UNLIMITED_RECORDS = 0
  SINGLE_RECORD = 1
  LIMITED_RECORDS = 2
  FIELD_TYPES = [:text_field, :text_area, :checkbox, :combobox, :options]
  DYNAMIC_ATTRIBUTE_TYPES = {
      :text => 0, :link => 1, :email => 2,
      :notes => 3, :address => 4, :phone => 5}

  serialize :fields
  belongs_to :topic

  named_scope :by_topic, lambda { |topic_id| {:conditions => {:topic_id => topic_id}}}

  def allows_more_entry?(topic, user)
    case record_insert_type
      when UNLIMITED_RECORDS
        return true
      when LIMITED_RECORDS
        return true
      when SINGLE_RECORD
        total_records = user.restaurants.by_topic(topic.id).count
        if total_records > 0
          return false
        else
          return true
        end
    end
  end

  def find_field(search_keyword)
    self.fields.each do |field|
      if (field['label'] || '').match(/#{search_keyword}/)
        return field
      end
    end
  end
end
