module TopicBasedTranslationHelper

  def tt(text, options = {})
    if @topic
      translation = @topic.translate_label(text, options)
      if !translation
        I18n.t(text)
      else
        I18n.t(translation)
      end
    else
      text
    end
  end
end