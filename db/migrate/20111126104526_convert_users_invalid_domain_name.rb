class ConvertUsersInvalidDomainName < ActiveRecord::Migration
  def self.up
    User.all.each do |user|
      user.update_attribute :domain_name, user.convert_to_subdomain
    end
  end

  def self.down
  end
end
