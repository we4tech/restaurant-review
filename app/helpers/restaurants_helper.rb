module RestaurantsHelper

  def render_most_lovable_places(p_limit = 5)
    render :partial => 'restaurants/parts/lovable_places', :locals => {:restaurants => Restaurant::most_loved}
  end

  def render_restaurant_review_stats(p_restaurant, p_short = true)
    reviews = p_restaurant.reviews
    if !reviews.empty?
      total_reviews_count = p_restaurant.reviews.count
      loved_count = p_restaurant.reviews.loved.count
      loved_percentage = (100 / total_reviews_count) * loved_count

      variables = {
          :total_reviews_count => total_reviews_count,
          :loved_count => loved_count,
          :loved_percentage => loved_percentage
      }

      render :partial => 'restaurants/parts/review_stats', :locals => variables
    end
  end
end
