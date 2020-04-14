require 'sinatra/base'
require 'sinatra/reloader'
require 'data_mapper'
require 'securerandom'
require_relative 'db'

class FossilMajig < Sinatra::Base
  register Sinatra::Reloader

  VERSION = "0.9.19"

  set :root, File.dirname(__FILE__)

  use Rack::Session::Cookie, :key => 'rack.session',
                             :path => '/',
                             :secret => 'benchdtails'

  DisplayUser = Struct.new(:username, :alias, :owned, :extra)
  WhoGot = Struct.new(:id, :fossil, :user)

  def needs_auth
    return !session[:user_id]
  end

  get '/' do
    redirect '/login' if needs_auth
    fossils = Fossil.all
    u = User.first username: session[:user_id]
    if u.nil?
      erb :login, :locals => { :nouser => true }
    else
      x = DisplayUser.new(u.username, u.alias, btoa(u.owned), btoa(u.extra))
      session[:alias] = u.alias
      erb :main, :locals => { :fossils => fossils, :user => x }
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
    u = User.first username: session[:user_id]
    if u.nil?
      erb :login, :locals => { :nouser => true }
    else
      x = DisplayUser.new(u.username, u.alias, btoa(u.owned), btoa(u.extra))
      erb :selfreport, :locals => { :fossils => fossils, :user => x }
    end
  end

  get '/allreport' do
    fossils = Fossil.all
    users = User.all({:alias.not => '0'})
    data = Array.new()
    users.each do |u|
      x = DisplayUser.new(u.username, u.alias, btoa(u.owned), btoa(u.extra))
      data.push(x)
    end
    erb :allreport, :locals => { :fossils => fossils, :users => data }
  end

  get '/whatuneed' do
    fossils = Fossil.all
    users = User.all({:alias.not => '0'})
    currentuser = User.first username: session[:user_id]
    x = DisplayUser.new(currentuser.username, currentuser.alias, btoa(currentuser.owned), 0)
    data = Array.new()
    # Find the IDs of the fossils the user needs
    fossils.each do |f|
      if x.owned[f.id].eql?("0")
        data.push(WhoGot.new(f.id, f.name, Array.new()))
      end
    end
    # Iterate through users to see who got wot
    users.each do |u|
      extra = btoa(u.extra)
      data.each do |d|
        if !extra[d.id].eql?("0")
          d.user.push(u.alias)
        end
      end
    end
    # Ok I think data has everything now?
    erb :whatuneed, :locals => { :user => x, :data => data }
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
end
