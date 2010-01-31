class AddEmailFooterToTopics < ActiveRecord::Migration
  def self.up
    add_column :topics, :email_footer, :text, :default => ''
    Topic.all.each do |topic|
      topic.update_attribute(:email_footer, %{
---------------------------------
WellTreatUs <support@welltreat.us>
Khawan Khawan!
---------------------------------
passionate food lovers community!
---------------------------------
})
    end
  end

  def self.down
    remove_column :topics, :email_footer
  end
end
