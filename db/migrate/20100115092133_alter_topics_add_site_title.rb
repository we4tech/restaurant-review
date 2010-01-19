class AlterTopicsAddSiteTitle < ActiveRecord::Migration
  def self.up
    add_column :topics, :site_title, :string, :default => nil
    add_column :topics, :site_labels, :text, :default => ''

    Topic.default.update_attribute(:site_title, 'Restaurant reviewer community')
  end

  def self.down
    remove_column :topics, :site_title
    remove_column :topics, :site_labels
  end
end
