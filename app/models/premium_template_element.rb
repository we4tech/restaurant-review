class PremiumTemplateElement < ActiveRecord::Base

  serialize :data

  belongs_to :premium_template
  belongs_to :restaurant
  belongs_to :user

  named_scope :by_element_key, lambda { |key| {:conditions => {:element_key => key}} }

  def author?(p_user)
    return p_user && p_user.id == self.user.id || (p_user && p_user.admin?)
  end

end
