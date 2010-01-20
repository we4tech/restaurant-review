module TopicBasedTranslationHelper

  def tt(text, options = {})
    translation = @topic.translate_label(text, options)
    if !translation
      return text
    else
      translation
    end
  end
end