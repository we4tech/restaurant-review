class AlterUsersAddCommentEmailNotification < ActiveRecord::Migration

  def self.up
    add_column :users, :email_comment_notification, :boolean, :default => 1
  end

  def self.down
    remove_column :users, :email_comment_notification
  end
end
