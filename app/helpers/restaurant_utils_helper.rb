module RestaurantUtilsHelper

	def single_or_multiple_value(value)
    if value.is_a?(Array)
      value
    else
      [value].compact
    end
  end  

  def render_if_owner_contact(restaurant)
    %{
    <a href='mailto:biz@welltreat.us?subject=[BIZ knock knock] About ##{restaurant.id} #{restaurant.name.gsub(/'/, '')}'
       title="#{t('title.own_this')}">
      #{image_tag('fresh/button_do_u_own_this.png')}
    </a>
    }
  end

  def render_properties(restaurant, options = {})
    except = options[:except] || []
    only = options[:only] || []
    preferred_label = options[:label]
    value_found = false
    
    full_html = content_tag 'div', :class => 'properties' do
      html            = ''
      excluded_fields = ['long_array', 'name', 'description', 'address']
      excluded_labels = []      
      
      @form_fields.each do |field|
        field_label = field['label']
        field_name  = field['field']
        field_type  = field['type']
        display     = field['display']
        field_value = field_name ? @restaurant.send(field_name) : nil
        
        value_present = field_value.present?
        only_this_field = only.include?(field_label.to_s.downcase)  
        not_blank_or_excluded = display && 
          !excluded_fields.include?(field_name.to_s) && !excluded_labels.include?(field_label.to_s)
        not_in_except = !except.include?(field_label.to_s.downcase)  

        if value_present && (only_this_field || (not_blank_or_excluded && not_in_except))
          value_found = true
          html << content_tag('div', preferred_label || field_label, :class => "grid_1 key #{url_escape(field_label)}")
          html << content_tag('div', format_content(field_type, field_value), :class => 'grid_3 value')
        end
      end
      
      if value_found
        html << content_tag('div', '', :class =>'clear')
        html << content_tag('div', '', :class =>'space_5')
      end
      
      html
    end
    
    if value_found
      full_html
    else
      nil
    end
  end

  def format_content(type, value)
    case type
      when 'checkbox'
        value == true ? 'yes' : 'no'

      when 'options'
        (value || []).collect { |t| link_to(t, section_url(t)) }.join(', ')

      else
        safe_textilize(value)
    end
  end 

end