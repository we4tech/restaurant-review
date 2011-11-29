module ImageResize
  class Util
    class << self
      def resize!(images)
        images.each do |image|
          orig_file_path = File.join(RAILS_ROOT, 'public', image.public_filename)
          temp_file_path = File.join(RAILS_ROOT, 'public', "#{image.public_filename}.tmp")
          puts "Original file - #{orig_file_path}"

          # Fix previously broken image
          if !File.exist?(orig_file_path) && File.exists?(temp_file_path)
            puts "Fixing broken image - #{image.id}"
            FileUtils.mv(temp_file_path, orig_file_path)
          end

          if File.exist?(orig_file_path)
            FileUtils.mv(orig_file_path, temp_file_path)

              # Update image object and reset temp file path
            data = {
                'content_type' => image.content_type,
                'filename' => image.filename,
                'tempfile' => temp_file_path,
                'size' => image.size
            }

            if image.update_attributes :uploaded_data => data
              puts "Reimaged - #{image.id}"
            end

            # Remove temp file
            FileUtils.rm_f(temp_file_path)
          end
        end
      end
    end
  end
end

namespace :welltreat do
  namespace :images do

    desc 'Reimage all existing images'
    task :reimage => :environment do
      images = nil
      cores = ENV['CORES'].to_i
      cores = cores == 0 ? 1 : cores

      if ENV['MODEL'].blank?
        puts 'USAGES: rake welltreat:images:reimage MODEL=<User|TopicEvent|Restaurant|SelectedRestaurant> ID=<Selected Restaurant Id>'
        exit(0)
      end

      # If model is defined retrieve image from model
      if ENV['MODEL']
        case ENV['MODEL']
          when 'User'
            images = User.all.collect(&:image).compact
          when 'TopicEvent'
            images = TopicEvent.all.collect(&:all_images).compact.flatten.compact
          when 'Restaurant'
            images = Restaurant.all.collect(&:all_images).compact.flatten.compact
          when 'SelectedRestaurant'
            images = Restaurant.find(ENV['ID']).all_images
        end

      # Retrieve all existing parent images
      else
        images = Image.all(:conditions => ['parent_id IS NULL'], :order => 'id DESC')
      end

      if images.present?
        if cores == 1
          ImageResize::Util.resize!(images)
        else
          per_core = images.length / cores
          cores.times do |i|
            fork do
              offset = i * per_core
              ActiveRecord::Base.connection.reconnect!

              puts "[CHILD #{i}] Offset - #{offset}..#{offset + (per_core - 1)}"
              set = images[offset..offset + (per_core - 1)]
              puts "[CHILD #{i}] Set (#{i}) first image id - #{set.first.id}"
              puts "[CHILD #{i}] Set (#{i}) last image id - #{set.last.id}"
              ImageResize::Util.resize!(set)
            end
          end
        end
      end
      # Done!

    end
  end
end