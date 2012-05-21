$: << File.expand_path(File.dirname(__FILE__))
$: << File.expand_path(File.dirname(__FILE__) + '/lib')
$: << File.expand_path(File.dirname(__FILE__) + '/app')

require 'bundler/setup'
Bundler.require(:default)

require 'main'
require 'config/config'
require 'background'
require 'config/audio-mime-types'

run AsyncHTML5Tunes::Config.routes
