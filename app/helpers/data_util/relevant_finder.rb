module DataUtil::RelevantFinder

  #
  # Find places which is more relevant to the user based on her previous participation behavior
  # We will be determining user participation behavior based on their reviews and reviewed restaurants tags
  #
  def relevant_places(topic, tag_group)
    user_and_suggested_places = {}

    # Prepare a list of users which has at least one review
    reviewers = find_reviewers(topic)

    reviewers.each do |reviewer|

      # Prepare a list of frequently reviewed restaurants for the specific user (only top two will be returned)
      frequently_reviewed_restaurants = find_frequently_reviewed_restaurants(topic, reviewer)

      # Extract cuisine tags from the top 2 frequently reviewed restaurants
      # Sort tags by their usages
      sorted_tags = extract_tags(frequently_reviewed_restaurants, tag_group)

      # Search by the tags
      suggested_restaurants = suggest_restaurants(topic, reviewer, sorted_tags[0..2])
      user_and_suggested_places[reviewer] = suggested_restaurants
    end

    # Send back the list of with the associated users.
    user_and_suggested_places
  end

  private
    #
    # Dangerous: This method is ok when we have limited users but it won't be ok when this set grows bigger.
    # For the devs: When it grows older and larger split it, distribute it and process it accordingly.
    #
    def find_reviewers(topic)
      User.all.collect{|u| u if u.reviews.count > 0}.compact
    end

    #
    # Find subscribed (reviewed or commented or something else) restaurants see which
    # restaurants has be reviewed several times and put that on the top
    #
    def find_frequently_reviewed_restaurants(topic, reviewer)
      restaurants = reviewer.subscribed_restaurants.by_topic(topic.id)
      frequency_with_restaurants = {}
      restaurants.each do |restaurant|
        frequency_with_restaurants[restaurant] ||= 0
        frequency_with_restaurants[restaurant] += 1
      end

      sorted = frequency_with_restaurants.sort{|v1, v2| v2.last <=> v1.last}

      # Take top 5 restaurants
      sorted[0..5]
    end

    #
    # Extract tags from the mostly participated restaurants
    # NOTE: Tags are sorted by their usages frequency
    #
    def extract_tags(frequently_reviewed_restaurants, tag_group)
      tags = frequently_reviewed_restaurants.collect{|r| r.first.tags_belongs_to(tag_group)}.flatten
      tag_usages_map = {}
      tags.each do |tag|
        tag_usages_map[tag] ||= 0
        tag_usages_map[tag] += 1
      end

      Tag.find_all_by_name(tag_usages_map.sort{|v1, v2| v2.last <=> v1.last}.collect{|t| t.first})
    end

    #
    # Suggest a list of restaurants if those restaurants were not reviewed by this reviewer before.
    # The twist is we are trying to suggest the randomize restaurants instead of most relevant
    #
    def suggest_restaurants(topic, reviewer, sorted_tags)
      # Max limit 5
      sorted_tags.collect{|t| t.restaurants_not_reviewed_by(reviewer)}.
          flatten.sort{|v1, v2| v2.created_at <=> v1.created_at}.flatten
    end
end
