class FormAttribute < ActiveRecord::Base

  UNLIMITED_RECORDS = 0
  SINGLE_RECORD = 1
  LIMITED_RECORDS = 2

  serialize :fields
  belongs_to :topic

  named_scope :by_topic, lambda { |topic_id| {:conditions => {:topic_id => topic_id}}}

end
