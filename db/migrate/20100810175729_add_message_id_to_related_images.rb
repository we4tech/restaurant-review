class AddMessageIdToRelatedImages < ActiveRecord::Migration
  def self.up
    add_column :related_images, :message_id, :integer
  end

  def self.down
    remove_column :related_images, :message_id
  end
end
