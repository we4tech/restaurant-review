class Tag < ActiveRecord::Base

  has_many :tag_mappings
  has_many :restaurants, :through => :tag_mappings
  
end
