var control = require('control'),
    script = process.argv[1],
    perform = control.perform,
    task = control.task;

/**
 * Project related configuration
 */
var ProjectConfig = {
  // Keep it simple word so we could use it for Rails environment too.
  rootDir: 'staging',

  // Git repository
  git: 'git://github.com/we4tech/restaurant-review.git',

  // Setup active branch
  branch: 'master',

  // Setup target server port
  serverPort: 4000,

  // Setup server access configuration
  serverConfig: {
    'staging': {
      'welltreat.us': {
        user: 'restaurantreview',
        sshOptions: ['-p 2212']
      }
    }
  }
};

var PC = ProjectConfig;

/**
 * Command generator
 */
var CommandBuilder = {

  buildServerCommand: function(start) {
    return 'cd ~/' + PC.rootDir + ' && /usr/bin/ruby1.8 /usr/local/bin/mongrel_rails cluster::' + (start ? 'start' : 'stop') +
        ' -C config/staging_mongrel.conf';
  },

  buildExecCommand: function() {
    var argv = (process.argv || []);
    var needle = argv.indexOf('exec');
    return "cd ~/" + PC.rootDir + " && " + argv.splice(needle + 1, argv.length).join(' ');
  },

  buildRakeCommand: function() {
    var argv = (process.argv || []);
    var needle = argv.indexOf('rake');
    var cmd = "cd ~/" + PC.rootDir + " && " + argv.splice(needle, argv.length).join(' ');

    if (cmd.indexOf('RAILS_ENV') == -1) {
      cmd += ' RAILS_ENV=' + PC.rootDir;
    }

    return cmd;
  },

  buildCodePullCommand: function() {
    return 'cd ~/' + PC.rootDir + ' && git checkout master && git pull';
  },

  buildSetupCommand: function() {
    var cmd = 'git clone ' + PC.git + ' ' + PC.rootDir + '';
    cmd += ' && mkdir ~/' + PC.rootDir + '/log ';
    cmd += ' && mkdir ~/' + PC.rootDir + '/tmp ';
    cmd += ' && mkdir ~/' + PC.rootDir + '/tmp/pids ';

    return cmd;
  },

  buildConfig: function(/* String */type) {
    return PC.serverConfig[type];
  },

  buildClearCacheCommand: function() {
    return "cd ~/" + PC.rootDir + ' && ' + 'rm -rf tmp/cache && ' +
           'rm -rf public/stylesheets/cache* && ' +
           'rm -rf public/javascripts/cache*'
  }
};

var CB = CommandBuilder;

/**
 * Retrieve environment related configuration
 */
task('staging', 'Config staging server', function() {
  return control.controllers(CB.buildConfig('staging'));
});

task('setup_dir', 'Setup project directory', function(c) {
});

task('setup_code', 'Update code base', function(c) {
  c.ssh(CB.buildSetupCommand());
});

task('setup', 'Setup whole project', function(c) {
  perform('setup_dir', c);
  perform('setup_code', c);
});

task('destroy', 'Destroy existing code base', function(c) {
  c.ssh('rm -rf ' + PC.rootDir);
});

task('update_code', 'Update code base', function(c) {
  c.ssh(CB.buildCodePullCommand());
});

task('start_server', 'Start server', function(c) {
  c.ssh(CB.buildServerCommand(true));
});

task('stop_server', 'Stop already running server processes', function(c) {
  c.ssh(CB.buildServerCommand(false));
});

task('restart_server', 'Restart server process', function(c) {
  c.ssh(CB.buildServerCommand(false) + ' && ' + CB.buildServerCommand(true));
});

task('rake', 'Execute rake at server end', function(c) {
  c.ssh(CB.buildRakeCommand());
});

task('exec', 'Execute command in server end', function(c) {
  c.ssh(CB.buildExecCommand());
});

task('update', 'Deploy code in staging server', function(controller) {
  perform('update_code', controller);
});

task('deploy', 'Deploy new code and restart server', function(c) {
  var cmds = [
      CB.buildCodePullCommand(), CB.buildClearCacheCommand(),
      CB.buildServerCommand(false), CB.buildServerCommand(true)
  ];

  c.ssh(cmds.join(' && '));
});

control.begin();