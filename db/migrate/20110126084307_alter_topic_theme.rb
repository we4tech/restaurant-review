class AlterTopicTheme < ActiveRecord::Migration
  def self.up
    Topic.all.each do |topic|
      if topic.theme && topic.theme == '01_fresh'
        topic.update_attribute(:theme, nil)
      end
    end
  end

  def self.down
  end
end
