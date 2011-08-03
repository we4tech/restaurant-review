module StringHelper

  def url_escape(text, sep = '-')
    return if text.nil?
    text.gsub(/[~`@#\$%\^&*()_\-\+=\|\\\}\]\{\["':;\?\/>\.<,\s]+/i, sep).downcase
  end

  #
  # This is intended for parsing default value passed with Topic form administration
  # Where this default value may contain special notation such as +"TG"+
  # Where +TG+ stands for TagGroup so it means all tags from tag group "TG:<Group name>"
  # ie. +TG:locations+
  # Will be taken as default value
  #
  # - In some cases existing value could be not listed under specific group so list them as well.
  #
  def parse_default_value(default_value, existing_value = [])
    values = (default_value || '').split(/\|/)
    values.collect! { |v| array_of_values_or_value(v) }
    values += existing_value
    values.flatten.uniq
  end

  def safe_textilize(s)
    if s && s.respond_to?(:to_s)
      doc             = RedCloth.new(s.to_s)
      doc.filter_html = true
      textilize_without_paragraph(doc.to_html)
    end
  end

  def friendly_truncate(text, options = {})
    words = options[:words] || 100
    characters = options[:characters] || 500 # 5 chars for each word * 100

    # No word based truncate truncate text only by characters
    if words == -1
      truncate(text, :length => characters)

    # Convert text into array of words and take preferred words
    # If total words + space length grows larger than the max sentence limit
    # Apply sentence limit if text limit wasn't set as -1
    else
      word_list = text.split(/\s/)
      words_for_new_text = word_list[0..words.to_i]
      new_text = words_for_new_text.join(' ')

      if characters != -1
        if new_text.length > characters
          truncate(new_text, :length => characters)
        else
          new_text
        end
      else
        new_text
      end
    end
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
