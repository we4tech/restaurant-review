class TagGroupMappingsController < ApplicationController

  def destroy
    tag_group_mapping = TagGroupMapping.find(params[:id].to_i)
    if tag_group_mapping.destroy
      notify :success, tag_group_tags_path(tag_group_mapping.tag_group_id)
    else
      notify :failure, tag_group_tags_path(tag_group_mapping.tag_group_id)
    end
  end
end
