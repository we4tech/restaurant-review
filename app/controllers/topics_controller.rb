require 'json'

class TopicsController < ApplicationController

  before_filter :authorize, :except => []
  before_filter :log_new_feature_visiting_status
  @@themes = []

  DEFAULT_MODULES = [
          {'name' => 'render_topic_box',
           'order' => 1,
           'label' => 'Review on more topics!',
           'enabled' => true,
           'limit' => -1,
           'bind_column' => ''},

          {'name' => 'render_tagcloud',
           'order' => 2,
           'enabled' => false,
           'limit' => 20,
           'label' => 'Tag cloud!',
           'bind_column' => 'string1'},

          {'name' => 'render_most_lovable_places',
           'order' => 3,
           'enabled' => true,
           'limit' => 5,
           'label' => 'Most loved places!',
           'bind_column' => ''},

          {'name' => 'render_recently_added_places',
           'order' => 4,
           'enabled' => true,
           'limit' => 10,
           'label' => 'Recently reviewed places!',
           'bind_column' => ''},

          {'name' => 'render_search',
           'order' => 5,
           'enabled' => true,
           'limit' => 10,
           'label' => 'Search places!',
           'bind_column' => ''},

          {'name' => 'render_related_restaurants',
           'order' => 6,
           'enabled' => true,
           'limit' => 5,
           'label' => 'Similar places!',
           'bind_column' => ''}
          ]

  def index
    @topics = Topic.recent.paginate(:page => params[:page])
  end

  def new
    @topic_object = Topic.new
    @themes = detect_themes(nil)
  end

  def edit
    @topic_object = Topic.find(params[:id].to_i)
    @themes = detect_themes(@topic_object)
  end

  def update
    @topic_object = Topic.find(params[:id].to_i)
    @site_labels = params[:site_labels]
    @site_labels = Topic::sanitize_site_labels(@site_labels)
    if @topic_object.update_attributes(params[:topic].merge(:site_labels => @site_labels))
      flash[:notice] = "Updated topic - '#{@topic_object.name}'"
      redirect_to edit_topic_url(:id => @topic_object.id)
    else
      @themes = detect_themes(@topic_object)
      render :action => :edit
    end
  end

  def create
    @topic_object = Topic.new(params[:topic])
    @site_labels = params[:site_labels]
    @topic_object.site_labels = @site_labels
    @topic_object.sanitize_site_labels!
    @topic_object.form_attribute = FormAttribute.new
    @topic_object.form_attribute.fields = [
            {'field' => 'name', 'type' => 'text_field', 'required' => true, 'index' => 0},
            {'field' => 'description', 'type' => 'text_area', 'required' => true, 'index' => 1},
            {'field' => 'address', 'type' => 'text_field', 'required' => true, 'index' => 2}]
    @topic_object.modules = DEFAULT_MODULES

    if @topic_object.save
      flash[:notice] = "Created new topic - '#{@topic_object.name}'"
      redirect_to topics_url
    else
      flash[:notice] = "Please fill up the red marked fields."
      @themes = detect_themes(nil)
      render :action => :new
    end
  end

  def destroy
    @topic_object = Topic.find(params[:id].to_i)
    if @topic_object.destroy
      flash[:notice] = "Removed topic - '#{@topic_object.name}'"
      redirect_to topics_url
    else
      flash[:notice] = "Failed to remove topic - '#{@topic_object.name}'"
      redirect_to :back
    end
  end

  def edit_modules
    @topic_object = Topic.find(params[:id].to_i)
    @module_names = DEFAULT_MODULES.collect{|m| m['name']}
    @all_modules = DEFAULT_MODULES.clone
    @bind_columns = Restaurant.column_names - [
        'description', 'address', 'id', 'created_at',
        'updated_at', 'user_id', 'lat', 'lng', 'topic_id'
    ]
  end

  def update_modules
    @topic_object = Topic.find(params[:id].to_i)
    (params[:modules] || []).sort!{|a, b| a['order'] <=> b['order']}
    if @topic_object.update_attribute(:modules, params[:modules])
      flash[:notice] = "Updated topic - '#{@topic_object.name}'"
      redirect_to edit_topic_modules_url(@topic_object.id)
    else
      flash[:notice] = 'Failed to update'
      redirect_to :back
    end
  end

  def export
    @topic_object = Topic.find(params[:id])
    respond_to do |format|
      format.xml {render(:xml => @topic_object)}
      format.json {
        send_data(@topic_object.to_json(:include => :form_attribute),
                  :filename => "#{@topic_object.name}.json",
                  :disposition => "attachment; filename=\"#{@topic_object.name}.json\"")
      }
    end
  end

  def import
    @topic_object = Topic.find(params[:id])
  end

  def import_uploaded_file
    @topic_object = Topic.find(params[:id])
    file = params[:file]

    if file
      if process_uploaded_file(@topic_object, file)
        flash[:notice] = 'Import succeeded!'
        redirect_to edit_topic_url(@topic_object.id)
      else
        if flash[:notice].nil?
          flash[:notice] = 'Import failed'
        end
        
        redirect_to :back
      end
    end
  end

  private
    def process_uploaded_file(topic, file)
      extension = file.original_filename.split('.').last.downcase
      case extension
        when 'json'
          return process_json_import(topic, file)
        when 'xml'
          flash[:notice] = 'Not supported right now!'
          return false
      end
    end

    def process_json_import(topic, file)
      fields = JSON.parse(file.read)
      importable_topic_attributes = fields['topic']

      # Remove id
      importable_topic_attributes.delete('id')
      if importable_topic_attributes.include?('form_attribute')
        importable_topic_attributes[:form_attribute] = FormAttribute.new(importable_topic_attributes['form_attribute'])
      end

      # Update attributes
      topic.update_attributes(importable_topic_attributes)
    end

    def detect_themes(topic)
      themes = []
      if topic
        Dir.glob(File.join(RAILS_ROOT, Topic::TEMPLATE_DIR, topic.subdomain, 'templates', '*')).each do |file|
          file_name = file.split('/').last
          themes << file_name
        end
      end

      themes
    end

end
