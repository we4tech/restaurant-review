class AlterUsersAddFacebookConnectEnabled < ActiveRecord::Migration

  def self.up
    add_column :users, :facebook_connect_enabled, :integer, :default => 1
  end

  def self.down
    remove_column :users, :facebook_connect_enabled
  end
end
