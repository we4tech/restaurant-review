class AddMetaTagsHtmlToTopics < ActiveRecord::Migration
  def self.up
    add_column :topics, :meta_tags_html, :text
  end

  def self.down
    remove_column :topics, :meta_tags_html
  end
end
