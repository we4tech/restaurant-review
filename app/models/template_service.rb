#
# Implement generic templating interface so we could use any view
# generating template engine.
module TemplateService

  class Engine
    
    class << self

      def render(topic, template_file, options = {})
        if template_file
          
        else
          raise "Template file not found - #{template_file}"
        end
      end

      #
      # Locate template from the generated template directory if not
      # found return nil
      def find_template_path(topic, file_name, format, options = {})
        path_prefix = RAILS_ROOT

        raise options.inspect
        if options[:layout]
          path_prefix = '../../../'    
        end

        template_file = File.join(path_prefix, Topic::TEMPLATE_DIR,
                                  topic.subdomain, 'templates',
                                  topic.theme, "#{file_name}.html.liquid")
        raise template_file.inspect
        if File.exists?(template_file)
          template_file
        else
          nil
        end
      end

    end
  end
end