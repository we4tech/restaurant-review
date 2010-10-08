class AddProductIdToRelatedImage < ActiveRecord::Migration
  def self.up
    add_column :related_images, :product_id, :integer
  end

  def self.down
    remove_column :related_images, :product_id
  end
end
