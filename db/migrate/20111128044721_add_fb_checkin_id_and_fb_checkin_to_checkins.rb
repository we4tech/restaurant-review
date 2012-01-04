class AddFbCheckinIdAndFbCheckinToCheckins < ActiveRecord::Migration
  def self.up
    add_column :checkins, :fb_checkin_id, :string
    add_column :checkins, :fb_checkin, :string
    add_column :checkins, :status, :integer
  end

  def self.down
    remove_column :checkins, :fb_checkin
    remove_column :checkins, :fb_checkin_id
    remove_column :checkins, :status
  end
end
