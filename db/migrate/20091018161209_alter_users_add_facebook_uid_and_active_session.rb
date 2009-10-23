class AlterUsersAddFacebookUidAndActiveSession < ActiveRecord::Migration
  def self.up
    add_column :users, :facebook_uid, :string
    add_column :users, :facebook_sid, :string
  end

  def self.down
    remove_column :users, :facebook_uid
    remove_column :users, :facebook_sid
  end
end
