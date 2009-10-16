#
# = Capistrano database.yml task
#
# Provides a couple of tasks for creating the database.yml
# configuration file dynamically when deploy:setup is run.
#
# Category::    Capistrano
# Package::     Database
# Author::      Simone Carletti
# Copyright::   2007-2009 The Authors
# License::     MIT License
# Link::        http://www.simonecarletti.com/
# Source::      http://gist.github.com/2769
#
#

unless Capistrano::Configuration.respond_to?(:instance)
  abort "This extension requires Capistrano 2"
end

Capistrano::Configuration.instance.load do

  namespace :shared_directories do

    desc 'Shared directories'
    task :setup, :except => { :no_release => true } do
      run "mkdir -p #{shared_path}/uploaded_images"
    end

    desc 'Update symblinks'
    task :symlink, :except => { :no_release => true } do
      run "ln -nfs #{shared_path}/uploaded_images #{release_path}/public/uploaded_images"
    end
  end

  after "deploy:setup",           "shared_directories:setup"
  after "deploy:finalize_update", "shared_directories:symlink"

end