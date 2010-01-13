class UserLog < ActiveRecord::Base

  belongs_to :user
  belongs_to :topic

  named_scope :by_topic, lambda{|topic_id| {:conditions => {:topic_id => topic_id}}}

end
