#!/bin/sh

echo 'Running "bundle install" to install gems... '
bundle install > /dev/null

echo 'Making sure iTunes is started... '
if [ -z "$( ps | grep iTunes )" ]; then
        echo
	echo "ERROR: iTunes not started!"
        echo "ERROR: Please start iTunes and try again."
	exit 1
fi

echo 'Making sure iTunes is playing a song... '
if [  "$( osascript -e 'tell application "iTunes" to player state as string'  )" != "playing" ]; then
        echo
        echo "ERROR: iTunes is not playing a song!"
        echo "ERROR: Please play a song and try again."
        exit 1
fi

echo 'Running rackup to start html5tunes... '
exec rackup -s thin -E production
