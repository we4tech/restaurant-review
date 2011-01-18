class AddCustomCssToTopicEvents < ActiveRecord::Migration
  def self.up
    add_column :topic_events, :custom_css, :text
  end

  def self.down
    remove_column :topic_events, :custom_css
  end
end
