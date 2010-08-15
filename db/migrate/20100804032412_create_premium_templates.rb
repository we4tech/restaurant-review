class CreatePremiumTemplates < ActiveRecord::Migration
  def self.up
    create_table :premium_templates do |t|
      t.integer :restaurant_id
      t.integer :user_id
      t.string :name
      t.boolean :published, :default => false
      t.string :site_title
      t.string :template, :null => false
      t.text :meta_tags

      t.timestamps
    end
  end

  def self.down
    drop_table :premium_templates
  end
end
