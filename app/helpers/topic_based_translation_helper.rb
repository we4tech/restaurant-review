module TopicBasedTranslationHelper

  def tt(text, options = {})
    translation = @topic.translate_label(text)
    if !translation
      return text
    else
      translation
    end
  end
end