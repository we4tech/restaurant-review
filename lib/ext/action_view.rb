ActionView::Helpers::UrlHelper.module_eval do
  alias_method :__url_for, :url_for

  def url_for(options = {})
    if options.is_a?(Hash)
      options.merge!({'l' => I18n.locale.to_s})
      __url_for(options)

    elsif options.is_a?(String)
      if options.match(/l=\w+/)
        options.gsub!(/l=(\w+)/, "l=#{I18n.locale.to_s}")
      elsif !options.match(/\?/)
        options << "?l=#{I18n.locale.to_s}"
      elsif options.match(/\?/)
        options << "&l=#{I18n.locale.to_s}"
      end

      __url_for(options)
    else
      __url_for(options)
    end
  end
end