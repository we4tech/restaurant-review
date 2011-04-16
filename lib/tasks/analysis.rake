namespace :welltreat do

  namespace :analysis do

    desc 'Find places which might be more relevant based on the user\'s previously reviewed places.'
    task :relevant_places => :environment do
      topic = Topic.find(ENV['TOPIC_ID'].to_i)
      tag_group = TagGroup.find_by_name!(ENV['TAG_GROUP_NAME'])

      raise DataAnalysisService::Analysis.relevant_places(topic, tag_group).collect{|k, v| [k.name, v.collect(&:name)]}.inspect
    end
  end
end