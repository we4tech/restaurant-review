class CreateTopics < ActiveRecord::Migration
  def self.up
    create_table :topics do |t|
      t.string :name
      t.string :label
      t.text :properties, :default => ''
      t.string :theme, :default => ''
      t.boolean :default, :default => false

      t.timestamps
    end

    add_index :topics, [:name]
    add_index :topics, [:default]

    # Create default topic
    Topic.create(
        :name => 'restaurant',
        :label => 'Restaurant, Cafe, Food and Eating out',
        :properties => '',
        :theme => '01_fresh',
        :default => true)
  end

  def self.down
    drop_table :topics
  end
end
