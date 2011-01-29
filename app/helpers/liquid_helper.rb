module LiquidHelper

  SIMPLE_SYNTAX = /^#{Liquid::QuotedFragment}+/

  module HtmlSupportingTags

    class Url < Liquid::Tag

      def initialize(tag_name, markup, tokens)
        super
        markup.strip!
        @named_route = markup.match(/['"]+(.+)['"]+/)[1]
      end

      def render(context)
        context['__controller'].__send__("#{@named_route}_url".to_sym)
      end
    end

    Liquid::Template.register_tag('url', Url)
  end
end
