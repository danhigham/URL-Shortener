require 'bundler/setup'
require 'sinatra/base'

Bundler.require(:default, ENV['RACK_ENV']) if defined?(Bundler)

# Init datamapper
DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, {:adapter  => "redis"})

# DataMapper.finalize

require 'shorten'
run UrlShortener
