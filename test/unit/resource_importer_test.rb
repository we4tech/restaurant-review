require 'test_helper'

class ResourceImporterTest < ActiveSupport::TestCase

  test "Successful import" do
    ri_count = ResourceImporter.count
    restaurants_count = Restaurant.count
    tags_count = Tag.count
    tag_mappings_count = TagMapping.count

    # Create mock request
    ri = ResourceImporter.new(
        :model => 'furniture_store',
        :data => File.new(File.join(RAILS_ROOT, 'test', 'fixtures', 'furniture-1.txt'), 'r')
    )

    assert_equal true, ri.import

    pp ri.inspect
    assert_equal ri_count + 1, ResourceImporter.count
    assert_equal restaurants_count + 1, Restaurant.count
    assert_equal 31, Restaurant.last.short_array.length
    assert_equal 55, Restaurant.last.long_array.length
  end

end
