module FormAttributesHelper

  #
  # Render dynamic holder for accommodating expandable dynamic fields
  # Parameters -
  #   model_name    - Domain model name
  #   field_name    - Model field name
  #   options       - Options for overriding features
  #   html_options  - Defining html class or id
  def render_dynamic_fields_container(model_name, field_name, options = {}, html_options = {})
    value = instance_variable_get("@#{model_name.to_s}").__send__(field_name) || {}
    name  = "#{model_name.to_s}[#{field_name}][]"
    render :partial => 'form_attributes/parts/dynamic_fields',
           :locals  => {:value => value, :name => name}
  end

  def render_options_field(options = {})
    default_value   = options[:value] || []
    field_label     = options[:label]
    field_name      = options[:name]
    field_type      = options[:type]
    search_bar      = options[:search_bar] || true
    required        = options[:required]
    placeholder     = options[:placeholder]
    group_prefix    = options[:group_prefix] || ''
    box_class       = options[:box_class] || 'tags'
    existing_value  = @restaurant.send(field_name) || []
    unsaved_options = []

    if @restaurant.new_tags.present?
      unsaved_options = @restaurant.new_tags[field_name] || []
    end

    html = ''

    # Render label if set
    if field_label
      html << content_tag('label', "#{tt("fields.#{(field_label.blank? ? field_name : field_label)}")}#{required ? ' (*)' : ''}")
      html << tag('br')
    end

    html << content_tag('div', :class => 'options_box') do
      box_html = ''

      # Render search bar
      if search_bar
        box_html << tag('input', {
            :name           => 'tag_search_keywords',
            :class          => 'tagSearchField searchIcon',
            :id             => "input_#{field_name}",
            :type           => 'search',
            :title          => "field_#{field_name}",
            :tag_type_field => "nt_#{field_name}",
            :fieldName      => field_name,
            :value          => placeholder
        })

        box_html << content_tag('select', :class => 'tagGroupName', :id => "nt_#{field_name}") do
          options_html = ''
          @topic.tag_groups.each do |tg|
            options_html << content_tag('option', "#{group_prefix}#{tg.name}", :value => tg.id)
          end

          options_html
        end

        box_html << content_tag('div', '', :class => 'clear')
      end

      # Render option fields
      box_html << content_tag('div', :class => box_class, :id => "field_#{field_name}") do
        options_html = ""
        parse_default_value(default_value, existing_value).sort.each do |option_name|
          option_name.strip!
          input_field_name = "restaurant[#{field_name}][]"
          options_html << build_option_field(option_name, existing_value, input_field_name, field_type)
        end

        if !unsaved_options.empty?
          unsaved_options.each do |unsaved_option|
            existing_value << unsaved_option
            input_field_name = "restaurant[new_tags][#{field_name}][]"
            options_html << build_option_field(unsaved_option, existing_value, input_field_name, field_type)
          end
        end
        options_html
        options_html << content_tag('div', '', :class => 'clear')
      end

      box_html
    end

    html << content_tag('div', '', :class => 'clear')
    html
  end

  private
  def build_option_field(option_name, existing_value, input_field_name, field_type)
    content_tag('div', :class => 'option') do
      option_field_id    = "option_#{url_escape(option_name)}"
      checked_state_hash = {}
      checked_state_hash[:checked] = 'checked' if existing_value.include?(option_name)

      option_html = tag('input',
                        {:id    => option_field_id, :type => 'checkbox',
                         :name  => input_field_name,
                         :value => option_name, :class => field_type}.merge(checked_state_hash))
      option_html << content_tag('label', (option_name || '').split('|').first, :for => option_field_id)
      option_html
    end
  end
end
