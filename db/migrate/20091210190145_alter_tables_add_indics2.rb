class AlterTablesAddIndics2 < ActiveRecord::Migration
  def self.up
    add_index :reviews, [:user_id]
  end

  def self.down
    remove_index :reviews, [:user_id]
  end
end
