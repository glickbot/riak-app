var gui = require('nw.gui');
var EventEmitter = require('events').EventEmitter;

var riakCwd = '../__RIAK_DIR__'
var appRunner = new EventEmitter();

var windowHidden = false;
var tray = new gui.Tray({ icon: 'img/riak.png' });
var menu = new gui.Menu();

var statusChecker = null;

var win = gui.Window.get();
win.width=1280;
win.height=768;

$( document ).ready(function() {
    build_nw_menu();
    start_riak();
});

function run_cmd(cmd, callback) {
  console.log("executing " + cmd)
  var exec = require('child_process').exec;
  exec(cmd, { cwd : riakCwd }, function(error, stdout, stderr) {
    console.log('stdout: ' + stdout);
    console.log('stderr: ' + stderr);
    console.log('exec error: ' + error);

    var result = {
      stdout: stdout,
      stderr: stderr,
      error: error,
      isError: null,
    }
    if ( error !== null ){
      result.isError = true;
      set_status("Error running '" + cmd + "': " + error);
    } else {
      result.isError = false;
    }
    callback(result);
  });
}

function build_nw_menu() {
  menu.append(new gui.MenuItem({
    label: 'show/hide',
    click: function() {
      if ( windowHidden ){
        gui.Window.get().show();
        windowHidden = false;
      } else {
        gui.Window.get().hide();
        windowHidden = true
      }
    }
  }));

  menu.append(new gui.MenuItem({
    label: 'quit',
    click: function() {
      set_status("Stopping Riak...");

      try {
        run_cmd('bin/stop_riak.sh', function(result){
          stop_status_check();
          set_status(result.stdout);
          document.getElementById('riak_control').contentWindow.location.reload();
          gui.Window.get().close(true);
        });
      } catch (err)  {
        console.log(err);
        gui.Window.get().close(true);
      }
    }
   }));
  tray.menu = menu;

  gui.Window.get().on('close', function (quit) {
    gui.Window.get().hide();
    windowHidden = true;
  });
}

function stop_riak() {
  set_status("Stopping Riak...");
  run_cmd('bin/stop_riak.sh', function(result){
    stop_status_check();
    set_status(result.stdout);
    document.getElementById('riak_control').contentWindow.location.reload();
  });

  return false;
}

function check_riak() {
  run_cmd('bin/check_riak.sh', function(result){
    set_status(result.stdout);
  });

  return false;
}

function start_status_check() {
  (function(){
      check_riak();
      statusChecker = setTimeout(arguments.callee, 10000);
  })();
}

function stop_status_check() {
  clearTimeout(statusChecker);
}

function start_riak() {
  set_status("Starting Riak and waiting for riak_kv...");

  run_cmd('bin/start_riak.sh', function(result){
      set_status(result.stdout);
      start_status_check();
  });

  return false;
}

function toggle_riak_control() {
  document.getElementById('riak_control').contentWindow.location.reload();
  $('#riak_control_section').toggle();
}

function toggle_riak_logs() {
  $('#riak_logs_section').toggle();

  run_cmd('tail -n20 log/console.log', function(result){
    document.getElementById('riak_logs').value = result.stdout;
  });
}

function set_status(str) {
  document.getElementById('status-text').innerHTML = str;
}
