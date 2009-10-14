class AlterRelatedImagesAddUserId < ActiveRecord::Migration
  def self.up
    add_column :related_images, :user_id, :integer
  end

  def self.down
    remove_column :related_images, :user_id
  end
end
