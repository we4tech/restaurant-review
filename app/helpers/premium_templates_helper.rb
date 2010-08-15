module PremiumTemplatesHelper

  AVAILABLE_MODULES = [
      :banner_image, :dynamic_menu,
      :big_image_gallery, :rich_text,
      :video_gallery, :recent_news]

  #
  # Render module of the specified type
  def render_module(type, options = {})
    if AVAILABLE_MODULES.include?(type)
      if @edit_mode
        send("edit_#{type.to_s}", options)
      else
        send(type, options)
      end
    else
      "No such module - #{type} found!"
    end
  end
end
