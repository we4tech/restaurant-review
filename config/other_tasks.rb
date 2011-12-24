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
      run "rm #{release_path}/tmp -rf"
      run "ln -nfs #{shared_path}/tmp #{release_path}/tmp"
    end

    desc 'Disable web site'
    task :web_disable do
      run "ln -nfs #{shared_path}/system/maintenance.html #{current_path}/public/index.html"
    end

    desc 'Enable web site'
    task :web_enable do
      run "rm #{current_path}/public/index.html"
    end
  end

  namespace :configuration do
    desc 'Create database configuration'
    task :mongrel do
      run "cd #{current_path} && /usr/local/rvm/gems/ruby-1.8.7-p352@rails2312/bin/mongrel_rails cluster::configure -c #{current_path} -e production -p 8000 -N 2"
    end

    desc 'Configure ultrasphinx'
    task :ultrasphinx do
      run "cd #{current_path} && rake ultrasphinx:configure RAILS_ENV=production"
    end
  end

  namespace :service do
    desc 'Mongrel cluster restart'
    task :mongrel_restart do
      run "/usr/local/rvm/gems/ruby-1.8.7-p352@rails2312/bin/mongrel_rails cluster::restart -C #{release_path}/config/mongrel_cluster.yml"
    end
  end

  after "deploy:setup", "shared_directories:setup"
  after "deploy:update", "shared_directories:symlink", "configuration:ultrasphinx", "configuration:mongrel", "service:mongrel_restart"
  #after "deploy:web:disable", "shared_directories:web_disable"
  #after "deploy:web:enable", "shared_directories:web_enable"

end