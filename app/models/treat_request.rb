class TreatRequest < ActiveRecord::Base

  belongs_to :restaurant

  cattr_accessor :per_page
  @@per_page = 20
  
end
