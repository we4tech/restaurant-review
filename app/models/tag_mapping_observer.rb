class TagMappingObserver < ActiveRecord::Observer

  def after_create(tag_mapping)
    tag_mapping.tag.increment!(:usages_count)
  end

  def after_destroy(tag_mapping)
    tag_mapping.tag.decrement!(:usages_count)
  end
end
