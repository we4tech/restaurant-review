class TopicsController < ApplicationController

  before_filter :authorize, :except => []
  before_filter :log_new_feature_visiting_status
  @@themes = []

  def index
    @topics = Topic.recent.paginate(:page => params[:page])
  end

  def new
    @topic = Topic.new
    @themes = detect_themes
  end

  def edit
    @topic = Topic.find(params[:id].to_i)
    @themes = detect_themes
  end

  def update
    @topic = Topic.find(params[:id].to_i)
    @site_labels = params[:site_labels]
    if @topic.update_attributes(params[:topic].merge(:site_labels => @site_labels))
      flash[:notice] = "Updated topic - '#{@topic.name}'"
      redirect_to edit_topic_url(:id => @topic.id)
    else
      @themes = detect_themes
      render :action => :edit
    end
  end

  def create
    @topic = Topic.new(params[:topic])
    @site_labels = params[:site_labels]
    @topic.site_labels = @site_labels
    @topic.form_attribute = FormAttribute.new
    @topic.form_attribute.fields = [
            {'field' => 'name', 'type' => 'text_field', 'required' => true, 'index' => 0},
            {'field' => 'description', 'type' => 'text_area', 'required' => true, 'index' => 1},
            {'field' => 'address', 'type' => 'text_field', 'required' => true, 'index' => 2}]
    if @topic.save
      flash[:notice] = "Created new topic - '#{@topic.name}'"
      redirect_to topics_url
    else
      flash[:notice] = "Please fill up the red marked fields."
      @themes = detect_themes
      render :action => :new
    end
  end

  def destroy
    @topic = Topic.find(params[:id].to_i)
    if @topic.destroy
      flash[:notice] = "Removed topic - '#{@topic.name}'"
      redirect_to topics_url
    else
      flash[:notice] = "Failed to remove topic - '#{@topic.name}'"
      redirect_to :back
    end
  end

  private
    def detect_themes
      if @@themes.empty?
        Dir.glob(File.join(RAILS_ROOT, 'config', 'themes', '*.yml')).each do |file|
          file_name = file.split('/').last.split('.').first
          @@themes << file_name
        end

        @@themes.sort!
        @@themes.collect{|t| [t.humanize, t]}
      else
        @@themes.collect{|t| [t.humanize, t]}
      end
    end

    def authorize
      if !current_user || !current_user.admin?
        flash[:notice] = 'You are not authorized to access this url.'
        redirect_to root_url
      end
    end
end
