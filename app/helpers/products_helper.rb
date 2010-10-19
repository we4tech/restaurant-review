module ProductsHelper

  AVAILABLE_TOOLS = [
      'review',
      'favorite',
      'purchased',
      'add_to_cart'
  ]

  #
  # List all related tools for products
  # ie. favorite, buy, reviews
  #
  def render_product_tools(options = {})
    parent_element = options[:parent_element] || 'ul'
    child_element = options[:child_element] || 'li'
    tools = options[:tools] || AVAILABLE_TOOLS


    html = "<#{parent_element} class='tools'>"

    tools.each do |tool_name|
      html << "<#{child_element}>"
      html << "<div class='nav product#{tool_name.capitalize}Icon'>"

      case tool_name
        when 'review'
          html << link_to(@product.reviews(:count), '#')

        when 'favorite'
          html << link_to(pt_image_tag('favorite_icon.png'), '#')

        when 'purchased'
          html << link_to(pt_image_tag('purchased_icon.png'), '#')

        when 'add_to_cart'
          html << link_to(pt_image_tag('add_to_cart.png'), '#')
      end

      html << "</div>"
      html << "</#{child_element}>"
    end

    html << "</#{parent_element}>"

    html
  end
end
