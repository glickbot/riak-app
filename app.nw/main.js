var gui = require('nw.gui');
var EventEmitter = require('events').EventEmitter;

var riakCwd = '../riak-2.0.4'

var appRunner = new EventEmitter();

appRunner.on('set gears', function(alt){
  document.getElementById('content').innerHTML = '<img id="gears" class="img-responsive" src="img/gears.svg" alt="' + alt + '"/>';
  // var gears = document.createElement('img');
  // gears.className = "img-responsive";
  // gears.src = "img/gears.svg";
  // document.getElementById('content').innerHTML(gears);
});

appRunner.on('start riak', function(cb){
  appRunner.emit('set gears', "Starting Riak");
  run_cmd('bin/riak start', function(result){
  //run_cmd('sh -c "sleep 5"', function(result){
    appRunner.emit('start riak returned', { result: result, callback: cb } );
  });
});

appRunner.on('start riak returned', function(start_return){
  if (start_return.result.isError){
    start_return.callback(start_return.result);
  } else {
    appRunner.emit('wait for riak', start_return);
  }
});

appRunner.on('wait for riak', function(start_return){
  run_cmd('bin/riak-admin wait-for-service riak_kv', function(result){
  //run_cmd('sh -c "sleep 5 && false"', function(result){
    if (result.isError){
      start_return.callback(result);
    } else {
      start_return.callback(start_return.result);
    }
  });
});

var windowHidden = false;

var tray = new gui.Tray({ icon: 'img/riak.png' });

var menu = new gui.Menu();

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
      disp_alert('danger', "Error running '" + cmd + "': " + error);
    } else {
      result.isError = false;
      //disp_alert('success', "Completed '" + cmd + "'");
    }
    callback(result);
  });
}

function disp_alert(type, msg) {
    var alert = document.createElement('div');
    alert.className = "alert alert-" + type + " alert-dismissible";
    alert.id = "riak_control";
    alert.innerHTML = msg;
    var nav = document.getElementById('nav_bar');
    nav.parentNode.insertBefore(alert, nav.nextSibling);
}

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
    appRunner.emit('set gears', "Starting Riak");
    try {
      run_cmd('bin/riak stop', function(result){
        if (result.isError !== true) {
          gui.Window.get().close(true);
        }
      });
    } catch (err)  {
      gui.Window.get().close(true);
    }
  }
 }));
tray.menu = menu;

gui.Window.get().on('close', function (quit) {
  gui.Window.get().hide();
  windowHidden = true;
});

appRunner.emit('start riak', function(result){
  console.log("Riak Startup Complete");
  if (result.isError){
    var alert = document.createElement('div');
    alert.className = "alert alert-danger";
    alert.innerHTML = "Unable to start riak";
    document.body.appendChild(alert);
  } else {
    document.getElementById('content').innerHTML = '<iframe id="riak_control" src="http://localhost:8098/admin"></iframe>'
  }
});
