class CreateUserLogs < ActiveRecord::Migration
  def self.up
    create_table :user_logs do |t|
      t.integer :user_id
      t.integer :topic_id

      t.timestamps
    end
  end

  def self.down
    drop_table :user_logs
  end
end
