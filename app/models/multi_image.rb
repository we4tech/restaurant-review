#
# Used for view form, it converts params to multiple images
class MultiImage

  attr_accessor :images, :uploaded_datum, :captions, :groups, :descriptions, :links

  def initialize(images = [])
    @images = []
    (images || []).each do |image_attributes|
      @images << Image.new(
          :caption => image_attributes[:captions],
          :uploaded_data => image_attributes[:uploaded_datum],
          :group => image_attributes[:groups],
          :description => image_attributes[:descriptions],
          :link => image_attributes[:links]
      )
    end

  end

  def user=(user)
    @user = user
    @images.each do |image|
      image.user = user
    end
  end

  def user
    @user
  end

  def topic_id=(topic_id)
    @topic_id = topic_id
    @images.each do |image|
      image.topic_id = topic_id
    end
  end

  def topic_id
    @topic_id
  end

  def group
    @images.each do |image|
      return image.group if !image.group.blank?
    end

    nil
  end

  def each(&block)
    @images.each do |image|
      block.call(image)
    end
  end

  def saved_all?
    @images.each do |image|
      image.save
    end

    successful?
  end

  def successful?
    return false if @images.empty?

    @images.each do |image|
      return false if !image.errors.empty?
    end

    true
  end
end