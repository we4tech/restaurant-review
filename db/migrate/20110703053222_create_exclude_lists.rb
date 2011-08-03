class CreateExcludeLists < ActiveRecord::Migration
  def self.up
    create_table :exclude_lists do |t|
      t.integer :topic_id
      t.integer :ref_id
      t.string :list_name
      t.string :object_type
      t.string :reason

      t.timestamps
    end

    add_index :exclude_lists, [:topic_id, :object_type]
  end

  def self.down
    drop_table :exclude_lists
  end
end
