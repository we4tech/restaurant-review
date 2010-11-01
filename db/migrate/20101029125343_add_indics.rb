class AddIndics < ActiveRecord::Migration
  def self.up
    add_index :premium_templates, [:hosts]
    add_index :tag_groups, [:name]
    add_index :tag_group_mappings, [:tag_group_id, :tag_id]
    add_index :restaurants, [:featured]
    add_index :tag_mappings, [:tag_id, :restaurant_id]
  end

  def self.down
    remove_index :premium_templates, [:hosts]
    remove_index :tag_groups, [:name]
    remove_index :tag_group_mappings, [:tag_group_id, :tag_id]
    remove_index :restaurants, [:featured]
    remove_index :tag_mappings, [:tag_id, :restaurant_id]
  end
end
