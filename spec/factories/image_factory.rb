Factory.sequence :image_title_name do |t|
  "image #{t}"
end

Factory.define :image, :class => Image do |i|
  i.caption Factory.next :image_title_name
end