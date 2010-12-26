class AddUserSubdomainToTopics < ActiveRecord::Migration
  def self.up
    add_column :topics, :user_subdomain, :boolean
  end

  def self.down
    remove_column :topics, :user_subdomain
  end
end
