class AddAsSectionAndSectionDataAndSectionIndexToTags < ActiveRecord::Migration
  def self.up
    add_column :tags, :as_section, :boolean
    add_column :tags, :section_data, :text
    add_column :tags, :section_index, :integer
  end

  def self.down
    remove_column :tags, :section_index
    remove_column :tags, :section_data
    remove_column :tags, :as_section
  end
end
