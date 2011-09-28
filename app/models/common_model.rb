module CommonModel

  module SyntheticExtentions

  end

  module LocationModel
    def located_in_map?
      self.lat.to_i > 0 && self.lng.to_i > 0
    end

    #
    # Find country from +address+ field, separate address by comma and take the last one
    def country
      if address.present?
        address.split(/,/).last.strip
      else
        nil
      end
    end
  end

  module CommonTopModel
    def map_any
      value_map = {}
      case self.any
        when Restaurant
          value_map[:restaurant_id] = self.any.id
        when TopicEvent
          value_map[:topic_event_id] = self.any.id
      end

      value_map
    end

    def map_any_object
      object_map = {}
      case self.any
        when Restaurant
          object_map[:restaurant] = self.restaurant
        when TopicEvent
          object_map[:topic_event] = self.topic_event
      end
      object_map
    end

    def ref_id
      self.restaurant_id || self.topic_event_id
    end

    def ref_id_name
      [:restaurant_id, :topic_event_id].each do |field_name|
        return field_name if self.respond_to?(field_name) && self.send(field_name).to_i > 0
      end
    end
  end

  module Common

    def author?(p_user)
      p_user && p_user.id == self.user.id || (p_user && p_user.admin?)
    end

    #
    # Check whether restaurant or topic event is attached with the review
    def any
      if restaurant
        restaurant
      elsif topic_event
        topic_event
      else
        nil
      end
    end
  end

  module ReviewModel
    def reviewed?(p_user, options = {})
      if p_user
        p_user.reviews.of_restaurant(self, options).count > 0
      end
    end

    def last_review
      reviews.find(:first, :order => 'id DESC')
    end

    def rating_out_of(p_scale = 5.0)
      total_loves   = self.reviews.loved.count.to_f
      total_reviews = self.reviews.count.to_f
      (total_loves / total_reviews) * p_scale
    end
  end

  module CheckinModel

    def already_checkedin?(user)
      self.checkins.by_users([user.id]).with_in(2.hours).first
    end
  end

end