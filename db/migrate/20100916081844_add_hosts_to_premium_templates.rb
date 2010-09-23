class AddHostsToPremiumTemplates < ActiveRecord::Migration
  def self.up
    add_column :premium_templates, :hosts, :string
  end

  def self.down
    remove_column :premium_templates, :hosts
  end
end
