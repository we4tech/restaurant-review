class AddExtraNotificationRecipientsToRestaurants < ActiveRecord::Migration
  def self.up
    add_column :restaurants, :extra_notification_recipients, :text
  end

  def self.down
    remove_column :restaurants, :extra_notification_recipients
  end
end
