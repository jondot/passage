require 'sinatra/base'

module Passage
  module Auth
  module PassPhrase
    module Helpers
      CK = '__phrase_ck'

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
      app.helpers Helpers

      app.get '/login' do
        "<form method='POST' action='/login'>" +
        "Your pass phrase<br/><input type='text' name='phrase'>" +
        "<input type='submit'/></form>"
      end

      app.post '/login' do
        if params[:phrase] == 'foo'
          session[:authorized] = true
          redirect '/'
        else
          session[:authorized] = nil
          redirect '/login'
        end
      end
    end
  end

  Sinatra.register PassPhrase
end
end
