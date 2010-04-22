namespace :welltreat do

  desc 'Update counter cache'
  task :update_counter => :environment do
    Tag.all.each do |tag|
      puts "Updating counter cache for - #{tag.name}"
      Tag::update_counters(tag.id, :tag_mappings_count => tag.tag_mappings.count)
    end
  end
end