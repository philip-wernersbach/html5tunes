HTML5Tunes
==========

Use your HTML5 browser to listen to music playing in iTunes!

Features
--------

* Client is pure HTML5, works in any browser that supports HTML5.
  Including Android and iOS.

* Client is controlled through iTunes.

* When available, uses preloading of audio to ensure smooth playback.

* Has settings for listening parties. (See send_sync_pulse in config.rb.)

* Minimal external dependencies.

Requirements
------------

1. Ruby 1.9
2. Bundler
3. OS X (We communicate with iTunes through Applescript.)
4. An HTML5 compatible browser.

Installation & Running
----------------------

In the directory you downloaded HTML5Tunes to, open a Terminal and run the following:

```
$ bundle install
```

This will install the required dependencies, which are not that much.

After this you can run the HTML5Tunes server by running the following command:

```
$ ./run.sh
```

Need a iTunes Control Interface?
--------------------------------

HTML5Tunes's sole purpose is to play iTunes songs in the browser. If you need to control iTunes from the web, I recommend [play](http://github.com/play/play), which
is also open source and written in Ruby. Since play controls iTunes through Applescript too, play and HTML5Tunes will work together.

Caveats
-------

Due to platform restrictions that are beyond my control, the HTML5Tunes mobile interface is currently a crapshoot.

1. iOS doesn't support more than one audio tag, so we can't preload songs. There will be a gap between songs.
2. Mobile Safari stops running Javascript when the screen is locked, so new songs won't play if the screen is locked.
3. Android's implementation of the audio tag is very, very buggy. I've tried to work around as many of these bugs as I can
   but YMMV still.

Todo
----

1. Refactor code to an 100% push architecture.
2. Do a general code cleanup.
