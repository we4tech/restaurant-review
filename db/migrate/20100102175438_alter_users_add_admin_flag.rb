class AlterUsersAddAdminFlag < ActiveRecord::Migration

  def self.up
    add_column :users, :admin, :boolean, :default => 0

    if default_admin = User.find_by_login('hasan')
      default_admin.update_attribute(:admin, true)
    end
  end

  def self.down
    remove_column :users, :admin
  end
end
