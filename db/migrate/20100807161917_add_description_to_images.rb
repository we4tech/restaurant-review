class AddDescriptionToImages < ActiveRecord::Migration
  def self.up
    add_column :images, :description, :text
    add_column :images, :link, :string
  end

  def self.down
    remove_column :images, :link
    remove_column :images, :description
  end
end
