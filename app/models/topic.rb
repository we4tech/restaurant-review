class Topic < ActiveRecord::Base

  validates_presence_of :name, :label
  after_save :set_default

  named_scope :recent, :order => 'created_at DESC'
  @@per_page = 20

  private
    def set_default
      if read_attribute(:default)
        Topic.update_all('`default` = 0', ['id <> ?', read_attribute(:id)])
      end
    end

end
