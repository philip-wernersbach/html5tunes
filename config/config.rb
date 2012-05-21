module AsyncHTML5Tunes

class Config

    def self.send_sync_pulse
        false
    end

    def self.song_url_base
        "/tunes"
    end
    
    def self.song_storage_directory
        File.join('public', 'tunes')
    end
    
    def self.redis_prefix
        "html5tunes_"
    end
    
    def self.routes
        @@routes
    end
    
    def self.redis_db
    end
    
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
