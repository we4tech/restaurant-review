module ModuleMenuHelper

  KEY_DYNAMIC_MENU = 'dynamic_menu'
  INTERNAL_LINKS = ['FOOD_MENU', 'NEWS', 'REVIEWS', 'LOGIN', 'REGISTER']

  #
  # Render dynamic menu editor
  def edit_dynamic_menu(options = {})
    object = template_element(options, KEY_DYNAMIC_MENU)
    editor = render :partial => 'menu/modules/edit_dynamic_menu',
                    :object => object
    viewable = dynamic_menu(options)

    %{
      <div id='in_edit_#{object.id}'>#{editor}<div class='clear'></div>#{viewable}</div>
    }
  end

  #
  # Render dynamic menu items
  def dynamic_menu(options = {})
    render :partial => 'menu/modules/dynamic_menu',
           :locals => {:menu => prepare_links(options)}
  end

  private
    def prepare_links(options = {})
      menus = []
      element = template_element(options, KEY_DYNAMIC_MENU)
      element.data.each_with_index do |menu_ref, index|
        external_link = menu_ref['ext_href']
        link_hint = menu_ref['int_href']
        label ||= menu_ref['label']

        display_link  = true
        existing_page = true
        url = nil

        if !(link_hint || '').blank?
          display_link, url, modified_label = expand_hinted_link(link_hint)
          label = modified_label || label

        elsif !external_link || external_link.blank?
          external_link = url_escape(label)
          existing_page = page_exists?(external_link)
          if pt_activate_no_reference_url?
            url = site_page_url(:page_name => external_link)
          else
            url = readable_page_url(@restaurant, :page_name => external_link)
          end

        elsif external_link && '/' == external_link
          if pt_activate_no_reference_url?
            url = '/'
          else
            url = premium_restaurant_url(@restaurant)
          end
        else
          url = external_link
        end

        if display_link
          menus << {:label => "#{label}#{!existing_page ? '*' : ''}",
                    :link => url,
                    :active => active_link?(url)}
        end
      end

      menus
    end

    def active_link?(url)
      request.url == url
    end

    def expand_hinted_link(int_link)
      display = true
      url = nil
      label = nil

      case int_link
        when 'FOOD_MENU'
          url = restaurant_food_items_url(@restaurant)

        when 'NEWS'
          if pt_activate_no_reference_url?
            url = site_messages_url
          else
            url = restaurant_messages_url(@restaurant)
          end

        when 'REVIEWS'
          if pt_activate_no_reference_url?
            url = site_reviews_url
          else
            url = restaurant_reviews_url(@restaurant)
          end

        when 'REGISTER'
          display = false if logged_in?
          url = register_url

        when 'LOGIN'
          if !logged_in?
            url = login_url
          else
            label = 'LOGOUT'
            url = logout_url
          end
      end

      return display, url, label
    end

end
