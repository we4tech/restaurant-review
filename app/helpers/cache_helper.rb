module CacheHelper

  # FIX: params[:page]
  def cache_path(controller, param_keys = [])
    param_keys << :page
    param_keys << :format
    value_string = param_keys.collect{|pk| controller.send(:params)[pk]}.compact.join('_')

    "#{controller.request.host}/#{controller.send(:controller_name)}/" +
    "#{controller.send(:action_name)}_#{params[:l] || I18n.locale.to_s}#{value_string.blank? ? '' : "_#{value_string}"}"
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
      def expire_caches(path, match)
        files = Dir.glob(File.join(RAILS_ROOT, 'tmp', 'cache', 'views', '*', path, '*'))
        files.each do |file|
          if file.match(/#{match}/)
            FileUtils.rm_rf(file)
          end
        end
      end
    end
  end
end
