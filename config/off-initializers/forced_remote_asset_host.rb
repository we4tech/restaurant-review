if 'development' == RAILS_ENV
  module ActionView
    module Helpers
      module AssetTagHelper

        def compute_public_path(source, dir, ext = nil, include_host = true)
          return source if source.to_s.match(/^http:\/\//)

          source = "#{source}.#{ext}" if ext.present? && !source.match(/\./)
          _path = []
          if source.to_s.match(/^\//)
            _path << source
          else
            _path << dir
            _path << source
          end

          "http://asset1.welltreat.us/#{_path.join('/')}"
        end
      end
    end
  end
end