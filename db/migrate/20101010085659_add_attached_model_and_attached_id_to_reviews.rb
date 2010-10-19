class AddAttachedModelAndAttachedIdToReviews < ActiveRecord::Migration
  def self.up
    add_column :reviews, :attached_model, :string, :default => nil
    add_column :reviews, :attached_id, :integer, :default => nil

    add_index :reviews, [:restaurant_id, :attached_model, :attached_id], :name => 'index_reviews_on_rid_am_ai'
  end

  def self.down
    remove_column :reviews, :attached_id
    remove_column :reviews, :attached_model

    remove_index :reviews, :name => 'index_reviews_on_rid_am_ai'
  end
end
