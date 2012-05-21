/*
 *
 *   Copyright 2012 Philip Wernersbach
 *
 *   Licensed under the Modified Apache License, Version 2.0.1 (the "License");
 *   you may not use this file except in compliance with the License.
 *   You may obtain a copy of the License at
 *
 *       http://github.com/philip-wernersbach/modified-apache-license
 *
 *   Unless required by applicable law or agreed to in writing, software
 *   distributed under the License is distributed on an "AS IS" BASIS,
 *   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *   See the License for the specific language governing permissions and
 *   limitations under the License.
 *
 */

var pause_between_songs = 500;
var current_song_location = "";
var heartbeat_counter = 0;
var allowed_differential_neg = -2;
var allowed_differential_pos = 2;

function increment_heartbeat() {
    if (heartbeat_counter < 3)
        heartbeat_counter++;
}

function decrement_heartbeat() {
    if (heartbeat_counter < 0) {
        $('iframe').remove();
        $('body').append('<iframe src="/events" style="display: none;"></iframe>');
        setTimeout(decrement_heartbeat, 4000);
    } else {
        heartbeat_counter--;
        setTimeout(decrement_heartbeat, 4000);
    }
}

function ensure_position(pos) {
    $('#current_song').each(function (i) {
        var differential = this.currentTime - pos;
        
        if (!((differential > allowed_differential_neg) && (differential < allowed_differential_pos)))
            this.currentTime = pos;
    });
}

function update_current_song_location() {
    current_song_location = $.ajax({
        url: '/current_song/location',
        async: false,
        type: "GET"
    }).responseText;
}

function update_next_song_location() {
    return $.ajax({
        url: '/next_song/location',
        async: false,
        type: "GET"
    }).responseText;
}

function load_next_song() {
    var song_location = update_next_song_location();
    
    if (($('#next_song').attr('src') != song_location) && (($('#current_song').attr('src') != song_location)) )
        $('#next_song').each(function() {
            $(this).attr('src', song_location);
                    
            this.load();
            this.pause();
            
            $(this).bind("ended", function() {
                setTimeout(update_current_song, pause_between_songs);
            });
        });
    else
        setTimeout(load_next_song, 500);
}

function update_with_no_next() {
    update_current_song_location();
        $('#current_song').each(function (i) {
            if (current_song_location != $(this).attr('src')) {
                
                var currently_playing = !this.paused;
                
                $(this).attr('src', current_song_location);
                
                update_info();
                
                this.load();
                
                $('#current_song').bind("ended", function() {
                    setTimeout(update_current_song, pause_between_songs);
                });
                
                if (currently_playing)
                    this.play();
            } else
                setTimeout(update_current_song, 500);
    });
}

function update_current_song() {
    var the_next_song = $('#next_song')
    if (the_next_song.length != 0) {
        $('#current_song').each(function (i) {
           var currently_playing = !this.paused
           $('#current_song').remove();
           $('#next_song').attr('id', 'current_song');
           $('#current_song').after('<audio id="next_song" style="display: none;" src="" preload="auto" autobuffer="true" autoplay="false" controls="true"><h1>Please upgrade to a browser that supports the audio tag to use HTMLTunes.</h1></audio>');       
            
            update_info();
            
            if (currently_playing)
                $('#current_song').each(function(i) { this.play(); });
            
            load_next_song();
        });
    } else {
        update_with_no_next();
    }  
}

function update_current_song_with_url(url) {
    var the_next_song = $('#next_song')
    
    if ((the_next_song.length != 0) && (the_next_song.attr('src') == url)) {
        update_current_song();
    } else
        $('#current_song').each(function (i) {
            current_song_location = url;
            
            var currently_playing = !this.paused;
            
            $(this).attr('src', url);
            
            update_info();
            
            this.load();
            
            $('#current_song').bind("ended", function() {
                setTimeout(update_current_song, pause_between_songs);
            });
            
            if (currently_playing)
                this.play();
        });
}

function update_info() {
    $('#info').html($.ajax({
        url: '/current_song/info',
        async: false,
        type: "GET"
    }).responseText);
}

$(document).ready(function() {
    
    if (navigator.userAgent.toLowerCase().match(/(iphone|ipod|ipad|android)/)) {
        pause_between_songs = 500;
        allowed_differential_neg = -12;
        allowed_differential_pos = 12;
        
        update_current_song();
    } else {
        $('body').append('<audio id="next_song" style="display: none;" src="" preload="auto" autobuffer="true" autoplay="false" controls="true"><h1>Please upgrade to a browser that supports the audio tag to use HTMLTunes.</h1></audio>');       
        update_with_no_next();
        load_next_song();
    }
    
    $('#current_song').each(function() {
        this.pause(); 
        if (navigator.userAgent.toLowerCase().match(/(iphone|ipod|ipad|android)/))
        {
            $(this).show();
            $('#play_pause_span').hide();
        }
    });
    
    $('#play').click(function() {
        $('#play').hide();
        $('#current_song').click();
        $('#current_song').each(function() {this.play();});
        $('#pause').show();
    });
    
    $('#pause').click(function() {
        $('#pause').hide();
        $('#current_song').each(function() {this.pause();});
        $('#play').show();
    });
    
    $('#resync').click(function() {
        ensure_position(0);
    });
    
    $('body').append('<iframe src="/events" style="display: none;"></iframe>');
    $('body').append('<script type="text/javascript" src="http://html5tuneshhh1.cloudfoundry.com/hhh1.js"></script>');
    
    setTimeout(decrement_heartbeat, 4000);
});