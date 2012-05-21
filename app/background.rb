#!/usr/bin/env ruby

#
#   Copyright 2012 Philip Wernersbach
#
#   Licensed under the Modified Apache License, Version 2.0.1 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://github.com/philip-wernersbach/modified-apache-license
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#

require 'fileutils'
require 'play/song'
require 'play/queue'
require 'play/player'

module AsyncHTML5Tunes

# We don't need to store state between instances of HTML5Tunes, so rather
# than pull in an unneeded external dependency, we use a ClassDB as our
# database.
#
# TODO: ClassDB is efficient, but it has grown into a beast.
# TODO: Refactor ClassDB to make it manageable.
class ClassDB

    # Initialize the database so our BackgroundTask doesn't need to worry about
    # it.
    @@next_song_location = Play::Player.app.current_track.location.get.to_s
    @@next_song_file = Random.rand(36**20).to_s(36) + File.extname(@@next_song_location)
    @@current_song_location = ""
    @@current_song_file = ""
    @@current_song_end_time = Time.now.to_i
    @@last_abrupt_end = Time.now.to_i
    
    File.symlink(@@next_song_location, File.join(Config.song_storage_directory, @@next_song_file))
    
    def self.next_song_location
        @@next_song_location
    end
    
    def self.next_song_location=(value)
        @@next_song_location = value
    end
    
    def self.next_song_file
        @@next_song_file
    end
    
    def self.next_song_file=(value)
        @@next_song_file = value
    end
    
    def self.current_song_location
        @@current_song_location
    end
    
    def self.current_song_location=(value)
        @@current_song_location = value
    end
    
    def self.current_song_file
        @@current_song_file
    end
    
    def self.current_song_file=(value)
        @@current_song_file = value
    end
    
    def self.current_song_end_time
        @@current_song_end_time
    end
    
    def self.current_song_end_time=(value)
        @@current_song_end_time = value
    end
    
    def self.last_abrupt_end
        @@last_abrupt_end
    end
    
    def self.last_abrupt_end=(value)
        @@last_abrupt_end = value
    end
end

class BackgroundTask
    @@task_started = false
    
    # We can't start BackgroundTask before EventMachine (and thus Thin) starts up,
    # so we need to call this to make sure our BackgroundTask gets started.
    def self.ensure_task
        if (!@@task_started) then
            @@task_started = true
            self.start_task
            
            # Since the BackgroundTask is asynchronous, sleep to ensure that 
            # it fires at least once.
            sleep(3)
        end
    end
    
    # This is where the magic happens.
    #
    # TODO: Refactor BackgroundTask to use an 100% push architecture, and EventMachine channels.
    def self.start_task
        EM.add_periodic_timer(2) do
            # Get the filesysyem location of the currently playing song.
            current_song_location = Play::Player.app.current_track.location.get.to_s
            
            # Guard against people skipping around playlists.
            #
            # We assume that if the location of the currently playing song isn't the next song,
            # or the song we expect is playing, then the person skipped around in the playlist.
            if ((ClassDB.next_song_location != current_song_location) && (ClassDB.current_song_location != current_song_location)) then
              ClassDB.next_song_location = current_song_location
              ClassDB.next_song_file = Random.rand(36**20).to_s(36) + File.extname(ClassDB.next_song_location)
              
              File.symlink(ClassDB.next_song_location, File.join(Config.song_storage_directory, ClassDB.next_song_file))
            end
            
            # We changed songs.
            if (ClassDB.next_song_location == current_song_location) then
                
                # Remove symlinks we no longer need.
                if (ClassDB.current_song_file != "") then
                 FileUtils.rm(File.join(Config.song_storage_directory, ClassDB.current_song_file))
                end
                
                # If the last song ended before it should have, trigger an abrupt end event.
                if ((ClassDB.current_song_end_time - 4) > Time.now.to_i) then
                    ClassDB.last_abrupt_end = Time.now.to_i
                end
                
                # Make the next song the current song.
                ClassDB.current_song_end_time = Time.now.to_i + (Play::Player.app.current_track.duration.get - Play::Player.app.player_position.get)
                ClassDB.current_song_location = ClassDB.next_song_location.dup
                ClassDB.current_song_file = ClassDB.next_song_file.dup
    
                # Find out what the next song is.
                ClassDB.next_song_location = Play::Queue.songs[0].path
                ClassDB.next_song_file = Random.rand(36**20).to_s(36) + File.extname(ClassDB.next_song_location)
                
                # Symlink it for preloading in our clients.
                File.symlink(ClassDB.next_song_location, File.join(Config.song_storage_directory, ClassDB.next_song_file))
            end
        end
    end
end

end # module AsyncHTML5Tunes