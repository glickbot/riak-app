riak-app
========

Riak App

#### What does this repo do?

It builds a OSX Mac App for a self-contained instance of Riak

#### What does the app do?

* Starts 1 Riak instance
* Opens riak control
* Creates a menu bar icon ( so you can show/hide the window )
* Lets you stop riak with the menu bar icon

#### What it should do?

* Run more than one instance
* Have a UI for better control

#### Building

    git clone https://github.com/glickbot/riak-app

    ./build.sh

Riak.app will be built in ./build_dir
