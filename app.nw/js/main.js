var gui = require('nw.gui');
var EventEmitter = require('events').EventEmitter;

var riakCwd = '../riak-2.0.4'
var appRunner = new EventEmitter();

var windowHidden = false;
var tray = new gui.Tray({ icon: 'img/riak.png' });
var menu = new gui.Menu();

var win = gui.Window.get();
win.width=800;
win.height=600;

$( document ).ready(function() {
    setup_event_callbacks();
    build_nw_menu();
    start_riak();
});

function setup_event_callbacks() {
  appRunner.on('start riak', function(cb){
    set_status("Starting Riak...");
    run_cmd('bin/riak start', function(result){
      appRunner.emit('start riak returned', { result: result, callback: cb } );
    });
  });

  appRunner.on('start riak returned', function(start_return){
    if (start_return.result.isError){
      start_return.callback(start_return.result);
    } else {
      set_status("Riak Started, waiting for riak_kv...");
      appRunner.emit('wait for riak', start_return);
    }
  });

  appRunner.on('wait for riak', function(start_return){
    run_cmd('bin/riak-admin wait-for-service riak_kv', function(result){
    //run_cmd('sh -c "sleep 5 && false"', function(result){
      if (result.isError){
        start_return.callback(result);
      } else {
        set_status("Riak Running");
        start_return.callback(start_return.result);
      }
    });
  });
}

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
        run_cmd('bin/riak stop', function(result){
          if (result.isError !== true) {
            set_status("Riak Stopped");
            gui.Window.get().close(true);
          } else {
            set_status("Unable to stop Riak: " + result.stderr);
            gui.Window.get().close(true);
          }
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
  run_cmd('bin/riak stop', function(result){
    if (result.isError !== true) {
      set_status("Riak Stopped");
    } else {
      set_status("Unable to stop Riak: " + result.stderr);
    }
  });
  return false;
}

function start_riak() {
  appRunner.emit('start riak', function(result){
    console.log("Riak Startup Complete");
    if (result.isError){
      if (result.stderr == "Node is already running!\n"){
        set_status("Riak Running");
      } else {
        set_status("Unable to start Riak: " + result.stderr);
      }
    } else {
      set_status("Riak Running");
    }
  });
  return false;
}

function toggle_riak_control() {
  document.getElementById('riak_control').contentWindow.location.reload();
  $('#riak_control_section').toggle();
  return false;
}

function toggle_riak_logs() {
  $('#riak_logs_section').toggle();

  run_cmd('tail -n20 log/console.log', function(result){
    document.getElementById('riak_logs').value = result.stdout;
  });

  return false;
}

function set_status(str) {
  document.getElementById('status-text').innerHTML = str;
}
