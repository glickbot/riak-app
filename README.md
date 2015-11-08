riak-app
========

Riak.app is a simple GUI wrapper for Riak on Mac OSX. Download the dmg file below to get started.

## Download

[http://riak-tools.s3.amazonaws.com/Riak211.dmg](http://riak-tools.s3.amazonaws.com/Riak211.dmg)

## Install

+ Double click Riak211.dmg
+ Click and drag Riak into your Applications folder

![image](https://raw.githubusercontent.com/basho-labs/riak-app/master/docs/install.png)

## Start Riak

After opening Riak.app, it will:

+ Start 1 Riak instance
+ Create a menu bar icon with buttons to show/hide the window

![image](https://raw.githubusercontent.com/basho-labs/riak-app/master/docs/getting_started.png)

## Usage

Once Riak is running, a few tasks can be performed from the left navigation drawer in the app interface:

+ View the Riak Control dashboard
+ View recent entries from console.log
+ Start / Stop Riak

![image](https://raw.githubusercontent.com/basho-labs/riak-app/master/docs/control.png)

The current status of Riak (Running or Stopped) can be found in the status bar at the top of the app interface.

![image](https://raw.githubusercontent.com/basho-labs/riak-app/master/docs/status.png)

## Stop Riak

Riak can be stopped using either of these methods:

+ Click the menu bar icon and select **quit**
+ Click **Actions -> Stop Riak** from the left navigation drawer

## Contributing

```
git clone https://github.com/basho-labs/riak-app
./build.sh
```

After downloading dependencies, Riak.app will be built in `./build_dir`

#### Version Changes

+ Modify `RIAK_PACKAGE_URL`, `RIAK_PACKAGE`, `RIAK_DIR`, and `RIAK_DMG` in `build.sh`
+ Run the following:

```
./clean.sh
./build.sh
./deploy.sh # AWS credentials required
```
