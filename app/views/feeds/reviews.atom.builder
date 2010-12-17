atom_feed(:url => feed_reviews_url(:format => :atom)) do |feed|
  feed.title(@topic.label)
  feed.tagline("Product review site!")
  feed.fullcount(@reviews.length)
  feed.modified(@reviews.first.created_at)
  feed.link(:rel => 'alternate', :href => root_url, :type => 'text/html')

  @reviews.each do |review|
    feed.entry(review) do |entry|
      if review.restaurant
        entry.title("Review on #{review.restaurant.name}")
        entry.summary(review.comment)
        entry.link(:rel => :alternate,
                   :href => "#{restaurant_long_url(review.restaurant)}#review-#{review.id}",
                   :type => 'text/html')
        entry.issued(review.created_at)
        entry.modified(review.updated_at)
        entry.author do |author|
          author.name(review.user.login)
        end
        entry.content :type => 'xhtml' do |xhtml|
          xhtml.div review.comment
          xhtml.div '<hr/>This review is attached with - '
          xhtml.div render(:partial => 'restaurants/parts/restaurant.html.erb', :locals => {:restaurant => review.restaurant, :only_html => true})
        end
      end
    end
  end
end               
