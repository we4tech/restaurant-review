module CacheHelper

  # FIX: params[:page]
  def cache_path(controller, param_keys = [])
    param_keys << :page
    param_keys << :format
    value_string = param_keys.collect{|pk| controller.send(:params)[pk]}.compact.join('_')

    "#{(request.env['HTTP_X_FORWARDED_HOST'] || controller.request.host)}/#{controller.send(:controller_name)}/" +
    "#{controller.send(:action_name)}_#{@topic.id}_#{params[:l]}#{value_string.blank? ? '' : "_#{value_string}"}"
  end

  def cache_fragment(fragment_key, &block)
    key = fragment_cache_key(fragment_key)
    if fragment_exist?(key)
      render :text => read_fragment(key)
    else
      write_fragment(key, block.call)
    end
  end

  def flush_fragment(fragment_key)
    expire_fragment(fragment_cache_key(fragment_key))
  end

  class Util
    class << self
      def expire_caches(path, match = nil)
        full_path_parts = [].tap do |array|
          array << [RAILS_ROOT, 'tmp', 'cache', 'views', '*', path]
          array << (match ? ['*'] : [])
        end.flatten

        files = Dir.glob(File.join(full_path_parts))

        count = 0
        files.each do |file|
          if match
            if file.match(/#{match}/)
              FileUtils.rm_rf(file)
              count += 1
            end
          else
            FileUtils.rm_rf(file)
            count += 1
          end
        end

        count
      end
    end
  end
end
