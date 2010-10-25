class AddTestHostToPremiumTemplates < ActiveRecord::Migration
  def self.up
    add_column :premium_templates, :test_host, :string
  end

  def self.down
    remove_column :premium_templates, :test_host
  end
end
