namespace :welltreat do
  namespace :images do

    desc 'Reimage all existing images'
    task :reimage => :environment do
      images = nil

      # If model is defined retrieve image from model
      if ENV['MODEL']
        case ENV['MODEL']
          when 'User'
            images = User.all.collect(&:image).compact
          when 'TopicEvent'
            images = TopicEvent.all.collect(&:all_images).compact.flatten.compact
        end

      # Retrieve all existing parent images
      else
        images = Image.all(:conditions => ['parent_id IS NULL'], :order => 'id DESC')
      end

      images.each do |image|
        orig_file_path = File.join(RAILS_ROOT, 'public', image.public_filename)
        temp_file_path = File.join(RAILS_ROOT, 'public', "#{image.public_filename}.tmp")

        # Fix previously broken image
        if !File.exist?(orig_file_path) && File.exists?(temp_file_path)
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
      # Done!

    end
  end
end