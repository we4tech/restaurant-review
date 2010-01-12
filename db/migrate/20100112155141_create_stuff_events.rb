class CreateStuffEvents < ActiveRecord::Migration
  def self.up
    create_table :stuff_events do |t|
      t.integer :topic_id
      t.integer :restaurant_id, :default => 0
      t.integer :image_id, :default => 0
      t.integer :user_id, :default => 0
      t.integer :review_id, :default => 0
      t.integer :review_comment_id, :default => 0
      t.integer :event_type, :default => 0

      t.timestamps
    end

    add_index :stuff_events, [:topic_id, :restaurant_id, :event_type], :name => 'by_topic_res_evt_type'
    add_index :stuff_events, [:topic_id, :restaurant_id, :event_type, :user_id], :name => 'by_topic_rest_evt_type_user'

    # Migrate existing data
    topic = Topic.default
    Review.all.each do |review|
      StuffEvent.create(
          :topic_id => topic.id,
          :restaurant_id => review.restaurant_id,
          :review_id => review.id,
          :user_id => review.user_id,
          :event_type => StuffEvent::TYPE_REVIEW,
          :created_at => review.created_at,
          :updated_at => review.updated_at)
    end

    ReviewComment.all.each do |review_comment|
      StuffEvent.create(
          :topic_id => topic.id,
          :restaurant_id => review_comment.restaurant_id,
          :user_id => review_comment.user_id,
          :review_id => review_comment.review.id,
          :review_comment_id => review_comment.id,
          :event_type => StuffEvent::TYPE_REVIEW_COMMENT,
          :created_at => review_comment.created_at,
          :updated_at => review_comment.updated_at)
    end

    Restaurant.all.each do |restaurant|
      StuffEvent.create(
          :topic_id => topic.id,
          :restaurant_id => restaurant.id,
          :user_id => restaurant.user_id,
          :event_type => StuffEvent::TYPE_RESTAURANT,
          :created_at => restaurant.created_at,
          :updated_at => restaurant.updated_at)
    end
  end

  def self.down
    drop_table :stuff_events
  end
end
