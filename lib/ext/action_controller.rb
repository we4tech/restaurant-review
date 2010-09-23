ActionController::Base::class_eval do
  alias_method :__url_for, :url_for

  def url_for(options = {})
    if options.is_a?(Hash)
      if !options.stringify_keys.include?('l')
        options.merge!({'l' => I18n.locale.to_s})
      end
      
      __url_for(options)

    elsif options.is_a?(String)
      if options.match(/l=\w+/)
        options.gsub!(/l=(\w+)/, "l=#{I18n.locale.to_s}")
      elsif !options.match(/\.(jpg|gif|png|swf|jpeg|ani|ico)$/)
        if !options.match(/\?/)
          options << "?l=#{I18n.locale.to_s}"
        elsif options.match(/\?/)
          options << "&l=#{I18n.locale.to_s}"
        end
      end

      __url_for(options)
    else
      __url_for(options)
    end
  end
end

ActionController::Session::CookieStore.class_eval do
  alias_method :__build_cookie, :build_cookie
  @@override_domain = nil
  cattr_accessor :override_domain

  def build_cookie(key, value)
    if @@override_domain
      value[:domain] = @@override_domain
    end

    __build_cookie(key, value)
  end
end