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

_RVM_ENV = 'source /usr/local/rvm/environments/ruby-1.8.7-p352@welltreatus'
_MONGREL_CMD_PREFIX = lambda {|s| "cd #{s.current_path} && #{_RVM_ENV} && '/usr/local/rvm/gems/ruby-1.8.7-p352@welltreatus/bin/mongrel_rails'" }

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
      run "#{_MONGREL_CMD_PREFIX.call(self)} cluster::configure -c #{current_path} -e production -p 8000 -N 2"
    end

    desc 'Configure ultrasphinx'
    task :ultrasphinx do
      run "cd #{current_path} && #{_RVM_ENV} && rake ultrasphinx:configure RAILS_ENV=production"
    end
  end

  namespace :service do
    desc 'Mongrel cluster restart'
    task :mongrel_restart do
      run "#{_MONGREL_CMD_PREFIX.call(self)} cluster::restart -C #{current_path}/config/mongrel_cluster.yml"
    end

    desc 'Stop mongrel process'
    task :mongrel_stop do
      run "#{_MONGREL_CMD_PREFIX.call(self)} cluster::stop -C #{current_path}/config/mongrel_cluster.yml"
    end

    desc 'Start mongrel process'
    task :mongrel_start do
      run "#{_MONGREL_CMD_PREFIX.call(self)} cluster::start -C #{current_path}/config/mongrel_cluster.yml"
    end

    desc 'Restart sphinx server'
    task :ultrasphinx_restart do
      run "cd #{current_path} && #{_RVM_ENV} && rake ultrasphinx:daemon:restart RAILS_ENV=production"
    end

    desc 'Stop sphinx server'
    task :ultrasphinx_stop do
      run "cd #{current_path} && #{_RVM_ENV} && rake ultrasphinx:daemon:stop RAILS_ENV=production"
    end

    desc 'Index all'
    task :ultrasphinx_index do
      run "cd #{current_path} && #{_RVM_ENV} && rake ultrasphinx:index RAILS_ENV=production"
    end

    desc 'Clean cache'
    task :clear_cache do
      run "cd #{current_path} && #{_RVM_ENV} && rake welltreat:clear_all_caches RAILS_ENV=production"
      run "cd #{current_path} && #{_RVM_ENV} && rm -rf tmp/cache"
    end

    desc 'Turn on maintenance page'
    task :maint_on do
      run "#{_MONGREL_CMD_PREFIX.call(self)} cluster::stop -C #{current_path}/config/mongrel_cluster.yml"
      run "/usr/local/bin/maintenance-page -P 8000 -m #{release_path}/public/down-site/ &"
      run "/usr/local/bin/maintenance-page -P 8001 -m #{release_path}/public/down-site/ &"
    end

    desc 'Turn on maintenance page'
    task :maint_off do
      run "killall maintenance-page"
      run "#{_MONGREL_CMD_PREFIX.call(self)} cluster::start -C #{current_path}/config/mongrel_cluster.yml"
    end

    desc 'Clear pids'
    task :clear_pids do
      run "cd #{current_path} && rm -rf tmp/pids/*.pid"
    end

    desc 'Automatically tag on git'
    task :auto_tag do
      tag_name = "release_#{Time.now.to_i}"
      last_heading = File.readlines('README.textile').
          select{|l| l if l.match(/^h4\./)}.
          first.gsub(/h4\.\s*/, '')
      `git tag #{tag_name} -m "#{last_heading}" && git push --tags`
    end

    desc 'Start server'
    task :start_server do
      [:clear_cache, :clear_pids, :ultrasphinx_restart, :mongrel_start].each do |task|
        execute_task tasks[task]
      end
    end
  end

  namespace :bundle do
    desc 'Install bundle'
    task :install do
      run "cd #{current_path} && bundle install"
    end
  end

  before 'deploy:setup', 'service:mongrel_stop', 'service:ultrasphinx_stop'
  after 'deploy:setup', 'shared_directories:setup'
  after 'deploy:update', 'shared_directories:symlink',
                         'configuration:ultrasphinx',
                         'configuration:mongrel'
  after 'deploy:update', 'service:mongrel_restart',
                         'service:ultrasphinx_restart',
                         'service:clear_cache'
  after 'deploy:update', 'service:auto_tag'

end