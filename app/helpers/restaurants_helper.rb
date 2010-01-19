module RestaurantsHelper

  def render_most_lovable_places(p_limit = 5)
    render :partial => 'restaurants/parts/lovable_places', :locals => {
        :title => 'Most loved places!',
        :more_link => most_loved_places_url,
        :restaurants => Restaurant.most_loved(@topic, p_limit)}
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

  def render_recently_added_places(p_limit = 10)
    render :partial => 'restaurants/parts/recently_reviewed_places', :locals => {
        :title => 'Recently reviewed places!',
        :more_link => recently_reviewed_places_url,
        :reviews => Review.by_topic(@topic.id).recent.all(:include => [:restaurant], :limit => p_limit)}
  end

  def render_recently_added_pictures(p_limit = 5)
    render :partial => 'restaurants/parts/recently_added_pictures', :locals => {
        :title => 'Recently added pictures!',
        :more_link => recently_reviewed_places_url,
        :restaurants => Restaurant.recently_added_pictures(p_limit)}
  end

  def render_who_wanna_go_there(p_restaurant, p_limit = 5)
    wanna_go_reviews = p_restaurant.reviews.by_topic(@topic.id).wanna_go.all(:limit => p_limit, :include => [:user])
    render :partial => 'restaurants/parts/who_wanna_go_there', :locals => {
        :title => 'Who wanna visit here!',
        :reviews => wanna_go_reviews,
        :more_link => who_wanna_go_place_url(:id => p_restaurant.id, :name => p_restaurant.name.parameterize.to_s)
    }
  end
end
