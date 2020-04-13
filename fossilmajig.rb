require 'sinatra/base'
require 'sinatra/reloader'
require 'data_mapper'
require 'securerandom'
require_relative 'db'

class FossilMajig < Sinatra::Base
  register Sinatra::Reloader

  VERSION = "0.8.8"

  set :root, File.dirname(__FILE__)

  use Rack::Session::Cookie, :key => 'rack.session',
                             :path => '/',
                             :secret => 'benchdtails'

  DisplayUser = Struct.new(:username, :alias, :owned, :extra)

  def needs_auth
    return !session[:user_id]
  end

  get '/' do
    redirect '/login' if needs_auth
    fossils = Fossil.all
    userdata = User.first username: session[:user_id]
    if userdata.nil?
      erb :login, :locals => { :nouser => true }
    else
      username = userdata.username
      owned = btoa(userdata.owned)
      extra = btoa(userdata.extra)
      session[:alias] = userdata.alias
      erb :main, :locals => { :fossils => fossils, :username => username, :owned => owned, :extra => extra }
    end
  end

  get '/login' do
    erb :login, :locals => { :nouser => false }
  end

  post '/savedata' do
    owned = params["owned"].values.join('')
    extra = params["extra"].values.join('')
    userdata = User.first username: session[:user_id]
    userdata.owned = owned
    userdata.extra = extra
    userdata.save
    redirect '/'
  end

  post '/newuser' do
    fossils = "0" * 73
    username = SecureRandom.uuid
    foo = User.new username: username, owned: fossils, extra: fossils
    foo.save
    session[:user_id] = username
    redirect '/'
  end

  get '/dologin/:userid' do
    session[:user_id] = params["userid"]
    redirect '/'
  end

  get '/alias' do
    erb :alias
  end

  post '/changealias' do
    nick = params["alias"]
    userdata = User.first username: session[:user_id]
    userdata.alias = nick
    userdata.save
    redirect '/'
  end

  get '/selfreport' do
    fossils = Fossil.all
    userdata = User.first username: session[:user_id]
    if userdata.nil?
      erb :login, :locals => { :nouser => true }
    else
      username = userdata.username
      owned = btoa(userdata.owned)
      extra = btoa(userdata.extra)
      session[:alias] = userdata.alias
      erb :selfreport, :locals => { :fossils => fossils, :username => username, :owned => owned, :extra => extra }
    end
  end

  get '/allreport' do
    fossils = Fossil.all
    users = User.all
    data = Array.new()
    users.each do |u|
      x = DisplayUser.new(u.username, u.alias, btoa(u.owned), btoa(u.extra))
      data.push(x)
    end
    erb :allreport, :locals => { :fossils => fossils, :users => data }
  end
    
  post '/loggedin' do
    session[:user_id] = params["user_id"]
    redirect '/'
  end

  get '/logout' do
    session.clear
    redirect '/'
  end

  def btoa(string)
    retval = string.split(//)
    if retval.length.eql?(0)
        foo = "0" * 73
        retval = foo.split(//)
    end
    retval.unshift("0")
  end

  def array_to_binary(arr)
    arr.join
  end

end
