class CreatePhotoComments < ActiveRecord::Migration
  def self.up
    create_table :photo_comments do |t|
      t.integer :image_id
      t.integer :user_id
      t.integer :restaurant_id
      t.text :content

      t.timestamps
    end
  end

  def self.down
    drop_table :photo_comments
  end
end
