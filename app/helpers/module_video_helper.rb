module ModuleVideoHelper

  KEY_VIDEO = 'video_gallery'

  def edit_video_gallery(options = {}, &block)
    element = template_element(options, KEY_VIDEO)

    if !block_given?
      render_edit_view(element)
    else
      render_edit_view_with_block(element, &block)
    end
  end

  def video_gallery(options = {}, &block)
    element = template_element(options, KEY_VIDEO)

    if !block_given?
      render :partial => 'video/modules/video_gallery',
             :object => element
    else
      render_view_with_block(element, &block)
    end
  end

  private
    def render_edit_view(element)
      render :partial => 'video/modules/edit_video_gallery',
             :object => element
    end

    def render_edit_view_with_block(element, &block)
      block.call(:edit, wrap_object({:html => render_edit_view(element)}))
    end

    def render_view_with_block (element, &block)
      (element.data || []).each_with_index do |video, index|
        block.call(:view, wrap_object(video))
      end
    end
end
