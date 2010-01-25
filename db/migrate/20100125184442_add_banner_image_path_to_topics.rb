class AddBannerImagePathToTopics < ActiveRecord::Migration
  def self.up
    add_column :topics, :banner_image_path, :string

    Topic.all.each do |topic|
      topic.update_attribute(:banner_image_path, '/images/fresh/icon.png')
    end
  end

  def self.down
    remove_column :topics, :banner_image_path
  end
end
