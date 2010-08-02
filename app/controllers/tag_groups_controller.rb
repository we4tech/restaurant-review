class TagGroupsController < ApplicationController

  before_filter :login_required
  before_filter :authorize, :except => []
  before_filter :log_new_feature_visiting_status

  def index
    @tag_groups = TagGroup.all
  end

  def new
    @tag_group = TagGroup.new
  end

  def create
    @tag_group = TagGroup.new(params[:tag_group])
    @tag_group.topic = @topic
    if @tag_group.save
      notify :success, tag_groups_path
    else
      notify :failure, :new
    end
  end

  def edit
    @tag_group = TagGroup.find(params[:id].to_i)
  end

  def update
    @tag_group = TagGroup.find(params[:id].to_i)
    if @tag_group.update_attributes(params[:tag_group])
      notify :success, tag_groups_path
    else
      notify :failure, :new
    end
  end

  def associate
    tag_group = TagGroup.find(params[:id].to_i)
    tags = Tag.find(params[:tags].collect(&:to_i))
    tags.each do |tag|
      TagGroupMapping.create(
          :tag => tag,
          :tag_group => tag_group,
          :topic => @topic
      )
    end

    flash[:success] = "We have associated - #{tags.length} tags!"
    redirect_to tag_group_tags_path(tag_group)
  end
end
