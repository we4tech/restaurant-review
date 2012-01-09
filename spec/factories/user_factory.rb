Factory.sequence :user_login do |n|
  "user_#{n}"
end

Factory.sequence :user_name do |n|
  "name_#{n}"
end

Factory.sequence :user_email do |n|
  "user#{n}@test.com"
end

Factory.define :user do |u|
  u.login { Factory.next :user_login }
  u.name { Factory.next :user_name }
  u.email { Factory.next :user_email }
  u.password 'test1234'
  u.password_confirmation 'test1234'
end