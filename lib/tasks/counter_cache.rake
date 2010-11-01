namespace :welltreat do

  desc 'Update counter cache'
  task :update_counter => :environment do
    Tag.all.each do |tag|
      puts "Updating counter cache for - #{tag.name}"
      Tag::update_counters(tag.id, :tag_mappings_count => tag.tag_mappings.count)
    end
  end

  desc 'Clear static cache'
  task :clear_all_caches => :environment do
    ['home', 'restaurants'].each do |dir|
      CacheHelper::Util.expire_caches(dir, '.+')
    end

    # clean static caches
    Dir.glob(File.join(RAILS_ROOT, 'public', 'javascripts') + '/cache*').each do |file|
      File.delete(file)
    end

    Dir.glob(File.join(RAILS_ROOT, 'public', 'stylesheets') + '/cache*').each do |file|
      File.delete(file)
    end
  end
end