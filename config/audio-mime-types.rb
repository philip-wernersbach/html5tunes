# Put your MIME type overrides for audio files here.

# For some reason, Rack uses a text MIME type for .m4a files,
# so make it use the correct MIME type.
Rack::Mime::MIME_TYPES['.m4a'] = 'audio/mp4'