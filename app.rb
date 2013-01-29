require 'rubygems'
require 'sinatra'
require 'mongoid'
# this is now using this https://github.com/treeder/rack-flash which is
# installed in the Gemfile as 'rack-flash3'
require 'rack-flash'
require 'digest/sha1'
require 'sinatra/reloader' if :development?

require_relative 'lib/helpers'
Dir[File.dirname(__FILE__) + '/models/*'].each {|file| require_relative file }

Mongoid.load!("config/mongoid.yml")

configure :test do
  puts 'Test configuration in use'
  puts 'env name = ' + Mongoid::Config::Environment.env_name.to_s
end
configure :development do
  puts 'Development configuration in use for cantoflash'
end
configure :production do
  puts 'Production configuration in use for cantoflash'
  disable :raise_errors
  disable :show_exceptions
end
set :mongo_logfile, File.join("log", "mongo-driver-#{settings.environment}.log")

# TODO the session should be written to the db
use Rack::Session::Cookie, :secret => 'thisisasecret'
use Rack::Flash

enable :sessions

configure :production, :test do
  not_found do
    erb :'404'
  end

  error do
    erb :'500'
  end
end

get '/' do
  unless session[:uid].nil?
    @current_user = User.where(:uid => session[:uid]).first
  end
  erb :index
end

['/collections', '/collections/index'].each do |path|
  get path do
    if session[:uid].nil?
      token_value = request.cookies["token"]
      if token_value.nil?
        redirect '/'
      end
      @token = verify_token(token_value)
      if @token[:value] == false
        redirect '/'
      end
      # token is genuine so set session:
      session[:uid] = @token["uid"]
    end
    @current_user = User.where(:uid => session[:uid]).first
    @collections = Collection.where(:uid.in => @current_user.collections)
    erb :'collections/index'
  end
end

get '/session/new' do
  unless request.cookies["error"].nil?
    @error = request.cookies["error"]
    response.set_cookie("error",
                        :domain => ".platform.local",
                        :path => "/",
                        :expires => Time.now )
  end

  erb :'session/new'
end

# TODO not exactly RESTful
get '/session/destroy' do
  invalidate = invalidate_token(request.cookies["token"])
  # TODO if it fails to invalidate then the token is still active on the auth
  # server...these tokens should have a server-side timeout anyway
  logger.info(invalidate)
  response.set_cookie("token",
                      :domain => ".platform.local",
                      :path => "/",
                      :expires => Time.now )
  session[:uid] = nil
  redirect '/'
end

