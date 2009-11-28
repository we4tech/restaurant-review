class AlterImagesAddCaption < ActiveRecord::Migration
  def self.up
    add_column :images, :caption, :string, :default => ''
  end

  def self.down
    remove_column :images, :caption
  end
end
