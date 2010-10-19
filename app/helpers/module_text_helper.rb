module ModuleTextHelper

  DEFAULT_KEY = 'rich_text'

  #
  # Render edit mode for rich text box
  def edit_rich_text(options = {})
    render :partial => 'rich_text/modules/edit_rich_text',
           :object => template_element(options, DEFAULT_KEY)
  end

  #
  # Render rich text content
  def rich_text(options = {})
    data = template_element(options, DEFAULT_KEY).data || [{}]
    if !data.empty?
      data.first['text']
    else
      'No Text was set'
    end
  end

  #
  # Split description text into several parts and toggle them through
  #"next" navigation button
  #
  def render_paginated_description(description, chars_length)
    html = ""
    html << tagify('div').css_class('description').content(description[0..chars_length]).html

    if description.length > chars_length
      parse_description_parts(description, chars_length, chars_length) do |part|
        html << tagify('div').css_class('description descPart').style('display:none').content(part).html
      end

      html << tagify('div').css_class('descriptionTools').
          content(tagify('a').href('javascript:void(0)').
                  onclick('$(".description").toggle()').
                  content('Next &raquo;').html).html
    end

    html
  end

  def parse_description_parts(description, index, length, &block)
    if description.length > index
      block.call(description[(index + 1)..(index + length)])
      parse_description_parts(description, index + length, length, &block)
    end
  end

  def tagify(tag_name)
    Tagify.new(tag_name)
  end

  class Tagify
    attr_accessor :tag_name, :attributes, :content

    def initialize(tag_name)
      @tag_name = tag_name
      @attributes = {}
      @content = nil
    end

    %w{css_class id style href onclick onblur onfocus height width}.each do |m|
      self.class_eval %{
        def #{m}(value)
          @attributes[:#{m.gsub(/css_/, '')}] = value
          self
        end
      }
    end

    def content(content)
      @content = content
      self
    end

    def html
      %{<#{@tag_name} #{@attributes.collect{|k, v| "#{k}='#{v}'"}.join(' ')}>#{@content}</#{@tag_name}>}
    end
  end
end
