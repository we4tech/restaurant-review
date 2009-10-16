require File.join(File.dirname(__FILE__), 'cap_symblink')

set :application, "restaurant-review"
set :repository,  "git://github.com/we4tech/restaurant-review.git"

set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

set :use_sudo, false

role :web, "fbwoguje.joyent.us", :user => 'dietrichyw'                          # Your HTTP server, Apache/etc
role :app, "fbwoguje.joyent.us", :user => 'dietrichyw'                          # This may be the same as your `Web` server
role :db,  "fbwoguje.joyent.us", :user => 'dietrichyw', :primary => true # This is where Rails migrations will run

set :deploy_to, "/users/home/dietrichyw/var/apps/#{application}"

# If you are using Passenger mod_rails uncomment this:
# if you're still using the script/reapear helper you will need
# these http://github.com/rails/irs_process_scripts

# namespace :deploy do
#   task :start {}
#   task :stop {}
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end
