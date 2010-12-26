class AddSubdomainContentTypeToTopics < ActiveRecord::Migration
  def self.up
    add_column :topics, :subdomain_content_type, :integer
  end

  def self.down
    remove_column :topics, :subdomain_content_type
  end
end
