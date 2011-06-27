require 'sinatra/base'
require 'omniauth'


  
module Passage
  module Auth
  module Omni
    module Helpers
      CK = '__omni_ck'

      def auth_setup(req) 
        session[CK] = req
      end

      def auth_fetch
        session[CK]
      end

      def auth_validate!(identity, trust_root) 
        redirect '/login' unless session[:authorized]
      end
    end

    def self.registered(app)
	
	  app.use Rack::Session::Cookie
      app.use OmniAuth::Builder do
        provider :facebook, '***api***', '***secret***', {:client_options => {:ssl => {:verify => false}}} 
      end
      app.helpers Helpers

      app.get '/login' do
        "<a href='/auth/facebook'>Sign in with Facebook</a><br/>"
      end

	  app.post '/auth/:name/callback' do
		auth = request.env['omniauth.auth']
        # do whatever you want with the information!
		puts auth.inspect
		session[:authorized] = true
		redirect '/'
	  end

	  app.get '/auth/:name/callback' do
		auth = request.env['omniauth.auth']
        # do whatever you want with the information!
		puts auth.inspect
		session[:authorized] = true
		redirect '/'
	  end
	  
    end
  end

  Sinatra.register Omni
end
end
