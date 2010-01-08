class CreateReviewComments < ActiveRecord::Migration
  def self.up
    create_table :review_comments do |t|
      t.integer :topic_id
      t.integer :review_id
      t.integer :user_id
      t.integer :restaurant_id
      t.integer :loved, :default => 1
      t.text :content

      t.timestamps
    end
  end

  def self.down
    drop_table :review_comments
  end
end
