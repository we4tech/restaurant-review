class AlterTablesAddTopicId < ActiveRecord::Migration

  def self.up
    default_topic = Topic.find_by_name('restaurant')
    add_column :contributed_images, :topic_id, :integer, :default => default_topic.id
    add_column :images, :topic_id, :integer, :default => default_topic.id
    add_column :related_images, :topic_id, :integer, :default => default_topic.id
    add_column :restaurants, :topic_id, :integer, :default => default_topic.id
    add_column :reviews, :topic_id, :integer, :default => default_topic.id

    add_index :contributed_images, [:topic_id, :image_id]
    add_index :contributed_images, [:topic_id, :restaurant_id]

    add_index :related_images, [:topic_id, :image_id]
    add_index :related_images, [:topic_id, :user_id]
    add_index :related_images, [:topic_id, :restaurant_id]

    add_index :restaurants, [:topic_id]

    add_index :reviews, [:topic_id, :restaurant_id]
    add_index :reviews, [:topic_id, :loved]
    add_index :reviews, [:topic_id, :user_id]

  end

  def self.down
    remove_column :contributed_images, :topic_id
    remove_column :images, :topic_id
    remove_column :related_images, :topic_id
    remove_column :restaurants, :topic_id
    remove_column :reviews, :topic_id
  end
end
