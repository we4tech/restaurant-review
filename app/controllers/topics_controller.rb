class TopicsController < ApplicationController

  before_filter :authorize, :except => []
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
    if @topic.update_attributes(params[:topic])
      flash[:notice] = "Updated topic - '#{@topic.name}'"
      redirect_to topics_url
    else
      @themes = detect_themes
      render :action => :edit
    end
  end

  def create
    @topic = Topic.new(params[:topic])
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
      if !current_user.admin?
        flash[:notice] = 'You are not authorized to access this url.'
        redirect_to root_url
      end
    end
end
