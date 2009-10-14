class CreateImages < ActiveRecord::Migration
  def self.up
    create_table :images do |t|
      t.integer :size, :height, :width, :parent_id, :user_id
      t.string :content_type, :filename, :thumbnail
      t.timestamps
    end
  end

  def self.down
    drop_table :images
  end
end
