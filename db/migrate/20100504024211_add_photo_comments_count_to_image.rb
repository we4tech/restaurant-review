class AddPhotoCommentsCountToImage < ActiveRecord::Migration
  def self.up
    add_column :images, :photo_comments_count, :integer, :default => 0
  end

  def self.down
    remove_column :images, :photo_comments_count
  end
end
