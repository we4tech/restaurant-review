class AddCssBackgroundToTopics < ActiveRecord::Migration
  def self.up
    add_column :topics, :css, :text, :default => ''
  end

  def self.down
    remove_column :topics, :css
  end
end
