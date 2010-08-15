module ModuleMenuHelper

  KEY_DYNAMIC_MENU = 'dynamic_menu'
  INTERNAL_LINKS = ['FOOD_MENU', 'NEWS', 'REVIEWS']

  #
  # Render dynamic menu editor
  def edit_dynamic_menu(options = {})
    key = options.stringify_keys['key'] || KEY_DYNAMIC_MENU
    editor = render :partial => 'menu/modules/edit_dynamic_menu',
                    :object => @premium_template.find_or_create_element(key)
    viewable = dynamic_menu(options)

    "#{editor}<div class='space_5 break'></div>#{viewable}"
  end

  #
  # Render dynamic menu items
  def dynamic_menu(options = {})
    key = options.stringify_keys['key'] || KEY_DYNAMIC_MENU

    render :partial => 'menu/modules/dynamic_menu',
           :locals => {:menu => prepare_links(key)}
  end

  private
    def prepare_links(key)
      menus = []
      element = @premium_template.find_or_create_element(key)
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
              url = restaurant_reviews_url(@restaurant)
          end
        elsif !link || link.blank?
          link = url_escape(label)
          existing_page = page_exists?(link)
          url = readable_page_url(
              :restaurant_id => @restaurant.id, :page_name => link)
        elsif link && '/' == link
          url = premium_restaurant_url(@restaurant)
        else
          url = link
        end

        menus << {:label => "#{label}#{!existing_page ? '*' : ''}", :link => url}
      end

      menus
    end

end
