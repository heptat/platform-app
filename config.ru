require 'rubygems'
require 'bundler/setup'
require 'sinatra'

Bundler.require

set :environment, :development
disable :run
enable :logging

require './app.rb'

run Sinatra::Application
