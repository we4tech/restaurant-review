var control = require('control'),
    script = process.argv[1],
    perform = control.perform,
    task = control.task;

var ProjectConfig = {
  rootDir: 'staging',
  git: 'git://github.com/we4tech/restaurant-review.git',
  branch: 'master',
  serverPort: 4000
};

function buildServerCommand(start) {
  return 'cd ~/' + ProjectConfig.rootDir + ' && /usr/bin/ruby1.8 /usr/local/bin/mongrel_rails cluster::' + (start ? 'start' : 'stop') +
         ' -C config/staging_mongrel.conf';
}

task('staging', 'Config staging server', function() {
  var config = {
    'welltreat.us': {
      user: 'restaurantreview',
      sshOptions: ['-p 2212']
    }
  };

  return control.controllers(config)
});

task('setup_dir', 'Setup project directory', function(c) {
  //c.ssh('mkdir ' + ProjectConfig.rootDir);
});

task('setup_code', 'Update code base', function(c) {
  var cmd = 'git clone ' + ProjectConfig.git + ' ' + ProjectConfig.rootDir + '';
  cmd += ' && mkdir ~/' + ProjectConfig.rootDir + '/log ';
  cmd += ' && mkdir ~/' + ProjectConfig.rootDir + '/tmp ';
  cmd += ' && mkdir ~/' + ProjectConfig.rootDir + '/tmp/pids ';
  c.ssh(cmd);
});

task('setup', 'Setup whole project', function(c) {
  perform('setup_dir', c);
  perform('setup_code', c);
});

task('destroy', 'Destroy existing code base', function(c) {
  c.ssh('rm -rf ' + ProjectConfig.rootDir);
});

task('update_code', 'Update code base', function(c) {
  c.ssh('cd ' + ProjectConfig.rootDir + ' && git checkout master && git pull');
});

task('start_server', 'Start server', function(c) {
  c.ssh(buildServerCommand(true));
});

task('stop_server', 'Stop already running server processes', function(c) {
  c.ssh(buildServerCommand(false));
});

task('restart_server', 'Restart server process', function(c) {
  c.ssh(buildServerCommand(false) + ' && ' + buildServerCommand(true));
});

task('rake', 'Execute rake at server end', function(c) {
  var argv = (process.argv || []);
  var needle = argv.indexOf('rake');
  var cmd = "cd " + ProjectConfig.rootDir + " && " + argv.splice(needle, argv.length).join(' ');

  if (cmd.indexOf('RAILS_ENV') == -1) {
    cmd += ' RAILS_ENV=' + ProjectConfig.rootDir;
  }

  c.ssh(cmd);
});

task('exec', 'Execute command in server end', function(c) {
  var argv = (process.argv || []);
  var needle = argv.indexOf('exec');
  var cmd = "cd " + ProjectConfig.rootDir + " && " + argv.splice(needle + 1, argv.length).join(' ');

  c.ssh(cmd);
});

task('update', 'Deploy code in staging server', function(controller) {
  perform('update_code', controller);
});

control.begin();