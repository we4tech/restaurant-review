module StringHelper

  def url_escape(text)
    text.parameterize.to_s
  end

  #
  # This is intended for parsing default value passed with Topic form administration
  # Where this default value may contain special notation such as +"TG"+
  # Where +TG+ stands for TagGroup so it means all tags from tag group "TG:<Group name>"
  # ie. +TG:locations+
  # Will be taken as default value
  #
  def parse_default_value(default_value)
    values = (default_value || '').split(/\|/)
    values.collect!{|v| array_of_values_or_value(v) }
    values.flatten.uniq
  end

  private
    def array_of_values_or_value(value)
      if value.match(/TG:(.+)/i)
        tag_group = TagGroup.of(@topic, $1)
        if tag_group
          tag_group.tags.collect(&:name)
        else
          value
        end
      else
        value
      end
    end
end
