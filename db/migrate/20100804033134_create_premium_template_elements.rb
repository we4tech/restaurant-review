class CreatePremiumTemplateElements < ActiveRecord::Migration
  def self.up
    create_table :premium_template_elements do |t|
      t.integer :premium_template_id
      t.integer :restaurant_id
      t.integer :user_id
      t.string :element_type
      t.string :element_key
      t.text :data

      t.timestamps
    end
  end

  def self.down
    drop_table :premium_template_elements
  end
end
