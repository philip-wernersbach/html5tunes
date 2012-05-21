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

require 'play/player'

module AsyncHTML5Tunes

# We use this to push events to our clients.
class DeferrableBody
  include EventMachine::Deferrable

  def call(body)
    if (body.class != Array) then
        @body_callback.call(body)
    else
        body.each do |chunk|
            @body_callback.call(chunk)
        end
    end
  end

  def each &blk
    @body_callback = blk
  end
end

# This pushes the events to clients.
#
# TODO: Use EventMachine channels.
class HTTPEvents
  AsyncResponse = [-1, {}, []]
  
  def self.call(env)
    # Ensure the BackgroundTask is running.
    BackgroundTask.ensure_task
    
    body = DeferrableBody.new
    
    # Store a copy of the last abrupt end for comparison.
    last_abrupt_end = ClassDB.last_abrupt_end
      
    # We've done all we can synchronously.
    EventMachine.next_tick do
      # Let the client know that something is here.
      env['async.callback'].call [200, {'Content-Type' => 'text/html', 'Connection' => 'Keep-Alive'}, body]
      
      # Some browsers will close the connection if it doesn't receive an arbitrary amount of data
      # in a certain amount of time, so push a bunch of useless data so that our connection stays open.
      EM.next_tick { 100.times { body.call "<span></span>\n" } }
    end
    
    EM.add_periodic_timer(3) do
    
        # A new abrupt end has arisen. Push a new song to clients.
        if (ClassDB.last_abrupt_end != last_abrupt_end) then
            last_abrupt_end = ClassDB.last_abrupt_end
            
            body.call "<script type=\"text/javascript\">window.parent.update_current_song_with_url(\"http://#{Rack::Request.new(env).host_with_port}#{Config.song_url_base}/#{ClassDB.current_song_file}\"); window.parent.increment_heartbeat();</script>"
        elsif ((Play::Player.app.player_position.get > 20) && Config.send_sync_pulse)
            # Don't send a position pulse within the first 20 seconds, just to ensure that all of our clients
            # finish their last song.
            body.call "<script type=\"text/javascript\">window.parent.ensure_position(#{Play::Player.app.player_position.get}); window.parent.increment_heartbeat();</script>"
        else
            # Make sure we send a heartbeat.
            body.call "<script type=\"text/javascript\">window.parent.increment_heartbeat();</script>"
        end
    end
    
    AsyncResponse
  end
end


# The rest of these classes are synchronously polled by clients.
# The problem is that this creates an awkward hybrid of polling and
# pushing.
#
# Don't rely on the polling API, it will be removed shortly.
#
# TODO: Refactor to an 100% push architecture.

class CurrentSongInfo
    def self.call(env)
        BackgroundTask.ensure_task
        [200, {'Content-Type' => 'text/html'}, "<div style=\"font-weight: bold;\">#{Play::Player.app.current_track.name.get.to_s}</div><div style=\"text-decoration: underline;\">#{Play::Player.app.current_track.album.get.to_s}</div><div>#{Play::Player.app.current_track.artist.get.to_s}</div>"]
    end
end

class CurrentSongLocation
    def self.call(env)
        BackgroundTask.ensure_task
        
        [200, {'Content-Type' => 'text/plain'}, "http://#{Rack::Request.new(env).host_with_port}#{Config.song_url_base}/#{ClassDB.current_song_file}"]
    end
end

class NextSongLocation
    def self.call(env)
        BackgroundTask.ensure_task
        
        [200, {'Content-Type' => 'text/plain'}, "http://#{Rack::Request.new(env).host_with_port}#{Config.song_url_base}/#{ClassDB.next_song_file}"]
    end
end

class LastAbruptStop
    def self.call(env)
        BackgroundTask.ensure_task
        
        [200, {'Content-Type' => 'text/plain'}, "#{ClassDB.last_abrupt_end}"]
    end
end

end # module AsyncHTML5Tunes
