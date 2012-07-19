class MigrateOldSectionData < ActiveRecord::Migration
  class Tag < ActiveRecord::Base;
    serialize :section_data
  end
  class Image < ActiveRecord::Base; end

  def self.up
    Tag.all.select{|t| t.section_data.present? }.each do |tag|
      if tag.section_data.is_a?(Array)
        r = Restaurant.find(tag.section_data.first.to_i)
        images = r.images_of('section', 0)
        if images.present?
          tag.update_attribute :section_data, { :sec_thumb => [images.first.image.id] }
          puts "Updated section_data for #{tag.name}"
        end
      end
    end
  end

  def self.down
  end
end
