class AddDisplayToImages < ActiveRecord::Migration
  def self.up
    add_column :images, :display, :boolean, :default => true
  end

  def self.down
    remove_column :images, :display
  end
end
