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
        format = format || :html

        if options[:layout]
          path_prefix = '../../../'    
        end

        File.join(path_prefix, Topic::TEMPLATE_DIR,
                  topic.subdomain, 'templates',
                  topic.theme, "#{file_name}.#{format.to_s}.liquid")
      end

    end
  end

  class Util
    class << self
      
      def public_asset_file(topic, file)
        File.join('/', Topic::TEMPLATE_DIR, topic.subdomain, topic.theme, "#{file}")
      end
    end
  end
end