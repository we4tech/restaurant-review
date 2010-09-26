class AddActivateNoReferenceUrlToPremiumTemplates < ActiveRecord::Migration
  def self.up
    add_column :premium_templates, :activate_no_reference_url, :boolean
  end

  def self.down
    remove_column :premium_templates, :activate_no_reference_url
  end
end
