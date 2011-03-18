#
# Avail template rendering related helper methods
module TemplateServiceHelper

  #
  # Render topic specific template if defined
  def render_topic_template(file_name, options = {})
    format = options[:format] || :html

    if !@topic.theme.blank?
      template_file = TemplateService::Engine.find_template_path(
          @topic, file_name, format, options)
      layout_file = TemplateService::Engine.find_template_path(
          @topic, 'layout', format, options.merge({:layout => true}))

      assign_common_variables
    end

    if defined?(template_file) && template_file
      render :template => template_file,
             :locals => options[:locals],
             :layout => layout_file
    else
      render :template => options[:default], 
             :locals => options[:locals],
             :layout => options[:layout]
    end
  end

  def assign_common_variables
    @asset_path = "/_generated/#{@topic.subdomain}/#{@topic.theme}/"
    @root_url = root_url
    @__controller = self 
  end
end
