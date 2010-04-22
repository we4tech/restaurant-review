module StringHelper

  def url_escape(text)
    text.parameterize.to_s
  end
end
