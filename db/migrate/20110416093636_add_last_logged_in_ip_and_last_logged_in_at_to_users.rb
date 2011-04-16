class AddLastLoggedInIpAndLastLoggedInAtToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :last_logged_in_ip, :string
    add_column :users, :last_logged_in_at, :datetime
  end

  def self.down
    remove_column :users, :last_logged_in_at
    remove_column :users, :last_logged_in_ip
  end
end
