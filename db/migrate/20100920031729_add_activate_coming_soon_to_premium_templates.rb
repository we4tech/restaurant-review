class AddActivateComingSoonToPremiumTemplates < ActiveRecord::Migration
  def self.up
    add_column :premium_templates, :activate_coming_soon, :boolean
    add_column :premium_templates, :activate_under_construction, :boolean
  end

  def self.down
    remove_column :premium_templates, :activate_coming_soon
    remove_column :premium_templates, :activate_under_construction
  end
end
