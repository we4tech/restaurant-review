module ReviewsHelper

  def render_review_box(restaurant, options = {})
    render :partial => 'reviews/parts/review_editor', :locals => {
        :restaurant => restaurant,
        :attached_options => options
    }
  end

  def render_reviews(restaurant, options = {})
    render :partial => 'reviews/parts/restaurant_review', :locals => {
        :restaurant => restaurant,
        :attached_options => options}
  end

end
