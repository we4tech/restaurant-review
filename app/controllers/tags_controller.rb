class TagsController < ApplicationController

  before_filter :login_required
  before_filter :log_new_feature_visiting_status

  def index
    if params[:tag_group_id]
      load_tag_group_tags
    else
      load_tags
    end
  end

  def create
    @tag = Tag.new(params[:tag])
    @tag.topic_id = @topic.id
    @tag.tag_mappings_count = 0

    if @tag.save
      notify :success, tags_url
    else
      load_tags
      notify :failure, :index
    end
  end

  def destroy
    @tag = Tag.find(params[:id].to_i)
    if @tag.destroy
      notify :success, tags_url
    else
      notify :failure, tags_url
    end
  end

  def sync
    tag_names_string = CGI.unescape(params[:tags])
    tag_names = tag_names_string.split("|").collect(&:strip)
    tags = @topic.tags.find_all_by_name(tag_names)
    found_tags = tags.collect(&:name)

    not_found_tags = tag_names - found_tags
    if !not_found_tags.empty?
      not_found_tags.each do |tag_name|
        Tag.create(:name => tag_name, :topic => @topic)  
      end
      flash[:success] = "We have sync - #{not_found_tags.length} new tags!"
    else
      flash[:notice] = 'No new tag found!'
    end

    redirect_to tags_path
  end

  private
    def load_tags
      @tags = @topic.tags
      @selected_tags = []
    end

    def load_tag_group_tags
      @tag_group = TagGroup.find(params[:tag_group_id].to_i)
      @tags = @topic.tags
      @selected_tags = @tag_group.tags.collect(&:id)
    end
end
