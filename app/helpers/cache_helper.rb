module CacheHelper

  # FIX: params[:page]
  def cache_path(controller, param_keys = [])
    param_keys << :page
    value_string = param_keys.collect{|pk| controller.send(:params)[pk]}.compact.join('_')
    "#{controller.request.host}/#{controller.send(:controller_name)}/" +
    "#{controller.send(:action_name)}_#{I18n.locale.to_s}#{value_string.blank? ? '' : "_#{value_string}"}"
  end

  class Util
    def self.expire_caches(path, match)
      files = Dir.glob(File.join(RAILS_ROOT, 'tmp', 'cache', 'views', '*', path, '*'))
      files.each do |file|
        if file.match(/#{match}/)
          File.delete(file)
        end
      end
    end
  end
end
