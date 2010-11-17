module I18n

  module Backend
    module ExtremeFallback

      @@fallback_maps = {}

      def map_fallbacks(for_locale, fallbacks)
        @@fallback_maps[for_locale] = fallbacks
      end

      def fallbacks(for_locale)
        @@fallback_maps[for_locale]
      end

      #
      # Look up translation if not found go with the fall back locales
      #
      def translate(locale, key, default_options = {})
        translation = super(locale, key, default_options)
        raise translation.inspect
      end

    end
  end
end