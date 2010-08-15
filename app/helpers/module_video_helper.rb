module ModuleVideoHelper

  KEY_VIDEO = 'video_gallery'

  def edit_video_gallery(options = {})
    key = options.stringify_keys['key'] || KEY_VIDEO
    render :partial => 'video/modules/edit_video_gallery',
           :object => @premium_template.find_or_create_element(key)
  end

  def video_gallery(options = {})
    key = options.stringify_keys['key'] || KEY_VIDEO
    render :partial => 'video/modules/video_gallery',
           :object => @premium_template.find_or_create_element(key)
  end
end
