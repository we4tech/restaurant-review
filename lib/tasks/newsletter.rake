namespace :welltreat do
  namespace :newsletter do

    desc 'Generate email list'
    task :email_list => :environment do
      puts "Generating email list"
      emails = []

      # Include all users
      User.all.each do |user|
        if user.email.present? && !user.email.match(/fake/)
          emails << "#{(user.name.present? ? user.name : user.login.humanize)}\t#{user.email}"
        end
      end

      # Include all restaurant owner side recipients
      Restaurant.all.each do |restaurant|
        if restaurant.extra_notification_recipients && !restaurant.extra_notification_recipients.empty?
          restaurant.extra_notification_recipients.each do |email|
            emails << "#{restaurant.name}'s admin\t#{email}"
          end
        end
      end

      puts emails.join("\n")
      puts "Total email addresses - #{emails.length}"
    end
  end
end