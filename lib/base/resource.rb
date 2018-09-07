require 'socket'
require 'uri'
require 'erb'

require 'base/parser'
require 'base/route'
require 'base/action'
require 'base/server'

require 'addons/erb_render'
require 'addons/explorer'

Thread::abort_on_exception = true

load '.http_config.rb' if File.exist?('.http_config.rb')
