namespace :welltreat do
  namespace :images do

    desc 'Reimage all existing images'
    task :reimage => :environment do
      # Retrieve all existing parent images
      Image.all(:conditions => ['parent_id IS NULL'], :order => 'id DESC').each do |image|
        orig_file_path = File.join(RAILS_ROOT, 'public', image.public_filename)
        temp_file_path = File.join(RAILS_ROOT, 'public', "#{image.public_filename}.tmp")

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
      # Done!

    end
  end
end