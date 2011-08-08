class Checkin < ActiveRecord::Base

  belongs_to :topic
  belongs_to :user, :counter_cache => true
  belongs_to :restaurant, :counter_cache => true
  belongs_to :topic_event, :counter_cache => true

  named_scope :by_topic, lambda { |topic_id| {:conditions => {:topic_id => topic_id}} }
  named_scope :by_week, lambda { |date| {:conditions => ['created_at >= ? AND created_at <= ?',
                                                         date.at_beginning_of_week, date.end_of_week]} }
  named_scope :by_restaurant, lambda { |restaurant_id|
    { :conditions => {:restaurant_id => restaurant_id} }
  }

  named_scope :most, lambda {
    {
        :select => 'checkins.*, count(checkins.restaurant_id) as visits',
        :group => 'checkins.restaurant_id', :order => 'visits DESC'
    }
  }

  named_scope :with_in, lambda {|hours|
    {
        :conditions => ['created_at BETWEEN ? AND ?', (Time.now - hours).utc, Time.now.utc]
    }
  }

  class << self

    # Find all check in leaders based on the most participation.
    # Sort user participation counts, by default returns only the
    # first  5 leaders
    def leaders(topic, limit = 5, offset = 0)
      excluded_list = LeaderBoardExcludeList.eat_outers.collect{|e| e.ref_id}
      excluded_list.empty? ? excluded_list << 0 : excluded_list

      checkiners = Checkin.all(
          :joins => [:user],
          :select => 'checkins.id, checkins.user_id, users.*, count(users.id) as pc',
          :group => 'users.id',
          :order => 'pc DESC',
          :offset => offset,
          :limit => limit,
          :conditions => ['checkins.topic_id = ? AND users.id NOT IN (?) ', topic.id, excluded_list]
      )

      users = User.find( checkiners.collect{|lu| lu.user_id} )

      leaders = []
      checkiners.each_with_index do |lu, index|
        leaders << [lu.pc, users[index]]
      end

      leaders
    end
  end
end
