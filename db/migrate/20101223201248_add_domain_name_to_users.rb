class AddDomainNameToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :domain_name, :string
    add_index :users, [:domain_name]
  end

  def self.down
    remove_column :users, :domain_name
  end
end
