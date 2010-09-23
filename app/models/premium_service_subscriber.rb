class PremiumServiceSubscriber < ActiveRecord::Base

  belongs_to :restaurant

  validates_presence_of :email
  validates_length_of :email,    :within => 6..100 #r@a.wk
  validates_uniqueness_of :email
  validates_format_of :email,    :with => Authentication.email_regex, :message => Authentication.bad_email_message

end
