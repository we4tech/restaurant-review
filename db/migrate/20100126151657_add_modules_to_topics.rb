class AddModulesToTopics < ActiveRecord::Migration
  def self.up
    add_column :topics, :modules, :text, :default => ''

    Topic.all.each do |topic|
      topic.update_attribute(:modules, [
          {'name' => 'render_topic_box',
           'order' => 1,
           'label' => 'Review on more topics!',
           'enabled' => true,
           'limit' => -1,
           'bind_column' => ''},

          {'name' => 'render_tagcloud',
           'order' => 2,
           'enabled' => false,
           'limit' => 20,
           'label' => 'Tag cloud!',
           'bind_column' => 'string1'},

          {'name' => 'render_most_lovable_places',
           'order' => 3,
           'enabled' => true,
           'limit' => 5,
           'label' => 'Most loved places!', 
           'bind_column' => ''},

          {'name' => 'render_recently_added_places',
           'order' => 4,
           'enabled' => true,
           'limit' => 10,
           'label' => 'Recently reviewed places!',
           'bind_column' => ''}
          ])
    end
  end

  def self.down
    remove_column :topics, :modules
  end
end
