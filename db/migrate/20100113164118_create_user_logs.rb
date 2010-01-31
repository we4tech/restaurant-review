class CreateUserLogs < ActiveRecord::Migration
  def self.up
    create_table :user_logs do |t|
      t.integer :user_id
      t.integer :topic_id

      t.timestamps
    end

    default_topic = Topic.default
    User.all.each do |user|
      UserLog.create(:user_id => user.id,
                     :topic_id => default_topic.id)
    end
  end

  def self.down
    drop_table :user_logs
  end
end
