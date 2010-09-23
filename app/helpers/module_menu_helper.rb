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
      <div id='in_edit_#{object.id}'>#{editor}<div class='space_5 break'></div>#{viewable}</div>
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
        label = menu_ref['label']
        link = menu_ref['ext_href']
        int_link = menu_ref['int_href']

        url = nil
        existing_page = true

        if !(int_link || '').blank?
          case int_link
            when 'FOOD_MENU'
              url = restaurant_food_items_url(@restaurant)

            when 'NEWS'
              url = restaurant_messages_url(@restaurant)

            when 'REVIEWS'
              url = site_reviews_url

            when 'REGISTER'
              url = register_url

            when 'LOGIN'
              url = login_url
          end
        elsif !link || link.blank?
          link = url_escape(label)
          existing_page = page_exists?(link)
          url = site_page_url(:page_name => link)
        elsif link && '/' == link
          url = premium_restaurant_url(@restaurant)
        else
          url = link
        end

        menus << {:label => "#{label}#{!existing_page ? '*' : ''}",
                  :link => url,
                  :active => active_link?(url)}
      end

      menus
    end

    def active_link?(url)
      request.url == url
    end

end
