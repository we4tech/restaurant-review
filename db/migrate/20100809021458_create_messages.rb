class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :messages do |t|
      t.integer :topic_id
      t.integer :restaurant_id
      t.integer :user_id
      t.integer :type_id
      t.string :title
      t.text :content
      t.text :related_objects

      t.timestamps
    end
  end

  def self.down
    drop_table :messages
  end
end
