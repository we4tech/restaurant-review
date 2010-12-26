class MigrateUsersDomainName < ActiveRecord::Migration
  def self.up
    User.all.each do |u|
      u.update_attribute(:domain_name, u.convert_to_subdomain)
    end
  end

  def self.down
    # nothing to rollback
  end
end
