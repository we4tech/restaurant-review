class AlterTopicsAddNewModule < ActiveRecord::Migration

  def self.up
    Topic.all.each do |topic|
      topic.update_attribute(:modules, (topic.modules || []) << {
          'name' => 'render_search',
          'order' => 5,
          'enabled' => true,
          'limit' => 10,
          'label' => 'Search ' + topic.name,
          'bind_column' => ''
      })
    end
  end

  def self.down
    Topic.all.each do |topic|
      topic.update_attribute(:modules, (topic.modules || []).reject{|m| m if m['name'] == 'render_search'})
    end
  end
end
