require 'test_helper'

class ImageTest < ActiveSupport::TestCase

  def test_image_destroy
    image = Image.create(
        :size => 124,
        :content_type => 'image/jpeg',
        :filename => 'abc.jpg')
    assert_not_nil image.id
    image_count = Image.count

    # Create Stuff event
    stuff_event = StuffEvent.create(
        :image_id => image.id,
        :restaurant_id => 1)
    assert_not_nil stuff_event.id
    stuff_event_count = StuffEvent.count

    # Delete Image
    assert_not_nil image.destroy
    assert_equal image_count - 1, Image.count
    assert_equal stuff_event_count - 1, StuffEvent.count
  end
end
