class AlterRestaurantsAddProperties < ActiveRecord::Migration
  def self.up
    add_column :restaurants, :string1, :string, :default => ''
    add_column :restaurants, :string2, :string, :default => ''
    add_column :restaurants, :string3, :string, :default => ''
    
    add_column :restaurants, :boolean1, :boolean, :default => false
    add_column :restaurants, :boolean2, :boolean, :default => false
    add_column :restaurants, :boolean3, :boolean, :default => false
    
    add_index :restaurants, [:string1] 
    add_index :restaurants, [:string2] 
    add_index :restaurants, [:string3]
    
    add_index :restaurants, [:boolean1] 
    add_index :restaurants, [:boolean2] 
    add_index :restaurants, [:boolean3]

    # Introduce label fields for other.
    FormAttribute.all.each do |form_attribute|
      fields = form_attribute.fields
      fields.each do |field|
        field['label'] = field['field']
      end
      form_attribute.update_attribute(:fields, fields)
    end
  end

  def self.down
    remove_column :restaurants, :string1
    remove_column :restaurants, :string2
    remove_column :restaurants, :string3

    remove_column :restaurants, :boolean1
    remove_column :restaurants, :boolean2
    remove_column :restaurants, :boolean3
  end
end
