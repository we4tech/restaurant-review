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

task('staging', 'Config staging server', function() {
  var config = {
    'welltreat.us': {
      user: 'restaurantreview',
      sshOptions: ['-p 2212']
    }
  };

  return control.controllers(config)
});

task('stop_server', 'Stop already running server processes', function(controller) {
  controller.ssh('date');
});

task('setup_dir', 'Setup project directory', function(c) {
  //c.ssh('mkdir ' + ProjectConfig.rootDir);
});

task('setup_code', 'Update code base', function(c) {
  var cmd = 'git clone ' + ProjectConfig.git + ' ' + ProjectConfig.rootDir + '';
  cmd += ' && mkdir ~/' + ProjectConfig.rootDir + '/log ';
  cmd += ' && mkdir ~/' + ProjectConfig.rootDir + '/tmp ';
  cmd += ' && mkdir ~/' + ProjectConfig.rootDir + '/tmp/pids ';
  console.log('Executing command - ' + cmd);
  c.ssh(cmd);
});

task('setup', 'Setup whole project', function(c) {
  // Make project dir
  perform('setup_dir', c);

  // Deploy code
  perform('setup_code', c);
});

task('update_code', 'Update code base', function(c) {
  c.ssh('cd ' + ProjectConfig.rootDir + ' && git checkout master && git pull');
});

task('start_server', 'Start server', function(c) {
  var cmd = '/usr/bin/ruby1.8 /usr/local/bin/mongrel_rails start -d -e ' +
      ProjectConfig.rootDir + ' -c ~/' + ProjectConfig.rootDir + ' -p ' +
      ProjectConfig.serverPort + ' -P ~/' +
      ProjectConfig.rootDir + '/tmp/pids/mongrel.' + ProjectConfig.serverPort +
      '.pid -l ~/'  + ProjectConfig.rootDir + '/log/mongrel.' + ProjectConfig.serverPort + '.log'
  c.ssh(cmd);
});

task('update', 'Deploy code in staging server', function(controller) {
  console.log('Updating...');

  // Stop servers
  //perform('stop_server', controller);

  // Update code
  perform('update_code', controller);

  // Start servers
});

control.begin();