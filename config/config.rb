# Pure Ruby configuration files FTW!

module AsyncHTML5Tunes

# We put all of our configuration data in this class.
class Config

    # When true, the server sends sync pulses to clients, to
    # make sure that they're listening to the same part of the song
    # at the same time.
    #
    # This is useful for listening parties.
    def self.send_sync_pulse
        false
    end

    # The path that clients use to retrieve songs.
    # This is with respect to our HTTP server.
    def self.song_url_base
        "/tunes"
    end
    
    # The path that we place symlinks, so that clients
    # can retrieve songs.
    # This is in respect to the base application
    # directory in the filesystem.
    def self.song_storage_directory
        File.join('public', 'tunes')
    end
    
    # An HTTPRouter object that is passed to Rack.run.
    def self.routes
        @@routes
    end
    
    # An HTTPRouter object that is passed to Rack.run.
    #
    # TODO: Clean this up. Use a loop.
    @@routes = HttpRouter.new do
        add('/').static(File.join('public', 'index.html'))
        add('/last_abrupt_stop').to(AsyncHTML5Tunes::LastAbruptStop)
        add('/js').static(File.join('public', 'js'))
        add(Config.song_url_base).static(File.join('public', 'tunes'))
        add('/events').to(AsyncHTML5Tunes::HTTPEvents)
        add('/current_song/location').to(AsyncHTML5Tunes::CurrentSongLocation)
        add('/current_song/info').to(AsyncHTML5Tunes::CurrentSongInfo)
        add('/next_song/location').to(AsyncHTML5Tunes::NextSongLocation)
    end
end

end # module AsyncHTML5Tunes
