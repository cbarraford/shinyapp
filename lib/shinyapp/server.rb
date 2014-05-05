require 'sinatra'
require 'haml'
require 'json'
require 'rest-client'

module Shinyapp
  class Server < Sinatra::Base

    begin
      require 'shiny/user'
      require 'shiny/cloudant'
      require 'shiny/chargify'
    rescue LoadError
      require_relative 'user'
      require_relative 'cloudant'
      require_relative 'chargify'
    end

    # config
    configure do
      use Rack::Session::Pool, expire_after: 2_592_000
      set :haml, format: :html5
      $stdout.sync = true
    end
    
    # HTML pages

    ['/user/*', '/api/*'].each do |path|
      before path do
        protected!
      end
    end

    get '/' do
      haml :index
    end

    get '/signup' do
      haml :signup
    end

    get '/success' do
      haml :success
    end

    get '/user/account' do
      haml :account
    end

    get '/login' do
      if logged_in?
        redirect '/user/account'
      else
        haml :login
      end
    end

    post '/login' do
      if validate(params[:username], params['passwd'])
        session[:logged_in] = true
        session[:username] = params[:username]
        redirect '/user/account'
      else
        haml :login, locals: { message: 'Incorrect username and/or password' }
      end
    end

    get '/logout' do
      clear_session
      redirect '/login'
    end

    # api endpoints
    get '/api/user' do
      user = Shinyapp::User.new(session[:username])
      user.to_json
    end

    # moved outside the /api route so you can create an account while not logged in
    post '/create' do
      user = JSON.parse(request.body.read, symbolize_names: true)
      user = Shinyapp::User.new(user)
      user.create.to_json
    end

    put '/api/user' do
      new_user = JSON.parse(request.body.read, symbolize_names: true)
      user = Shinyapp::User.new(session[:username])
      user.update(new_user).to_json
    end

    delete '/api/user' do
      user = Shinyapp::User.new(session[:username])
      user.delete.to_json
    end

    get '/api/user/subscriptions' do
      user = Shinyapp::User.new(session[:username])
      user.subscriptions.to_json
    end

    get '/api/user/billing' do
      user = Shinyapp::User.new(session[:username])
      user.billing.to_json
    end

    get '/api/chargify/payment_profiles/:id' do
      user = Shinyapp::User.new(session[:username])
      payment = Shinyapp::Chargify::Payment.get(params[:id])
      if payment[:customer_id] == user.chargify_id
        payment
      else
        {}
      end
    end

    post '/api/chargify/payment_profiles' do
      payment = JSON.parse(request.body.read, symbolize_names: true)
      Shinyapp::Chargify::Payment.create(payment)
    end

    put '/api/chargify/payment_profiles/:id' do
      payment = JSON.parse(request.body.read, symbolize_names: true)
      Shinyapp::Chargify::Payment.update(id, payment)
    end

    helpers do
      def validate(username, password)
        user = Shinyapp::User.new(username)
        !user.nil? && user.valid_passwd?(password)
      end

      def logged_in?
        session[:logged_in] == true && session[:username]
      end

      def force_session_auth
        if logged_in?
          return true
        else
          redirect '/login'
          return false
        end
      end

      def clear_session
        session.clear
      end

      def protected!
        unless logged_in?
          throw(:halt, [401, "Not authorized\n"])
        end
      end
    end
  end
end
