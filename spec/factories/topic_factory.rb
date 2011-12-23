Factory.sequence :topic_name do |n|
  "topic_#{n}"
end

Factory.sequence :topic_label do |n|
  "topic label #{n}"
end

Factory.sequence :topic_host do |n|
  "host#{n}.test.dev"
end

Factory.define :topic do |t|
  t.name { Factory.next :topic_name }
  t.user_subdomain true
  t.label { Factory.next :topic_label }
  t.hosts { Factory.next :topic_host }
end