class AddDescriptionToTopics < ActiveRecord::Migration
  def self.up
    add_column :topics, :description, :text

    Topic.all.each do |topic|
      topic.update_attribute(:description, %{
        why don't you review your favorite restaurant <b>NOW!</b>
        let your friends know which place you have been to recently.
        also let them know whether you <span class="icon_loved">loved it</span>
        or <span class="icon_hated">hated</span> so much!.
      })
    end
  end

  def self.down
    remove_column :topics, :description
  end
end
