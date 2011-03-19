require 'sinatra/base'

module Passage
  class App < Sinatra::Base
    alias_method :app, :options

    register Passage::Environment
    helpers Passage::OpenIDHelpers

    [:post, :get].each do |meth| 
      send meth, '/' do

        oidreq = nil
        begin
          oidreq = server.decode_request(params) || auth_fetch         
        rescue ProtocolError => e
        end

        return "This is an OpenID server endpoint." unless oidreq

        oidresp = nil
        if oidreq.kind_of?(CheckIDRequest)
          auth_setup(oidreq)

          identity = oidreq.identity
          auth_validate!(identity, oidreq.trust_root)
          oidresp = openid_positive_assertion(oidreq, identity, app.identities[identity])
        else
          oidresp = server.handle_request(oidreq)
        end

        openid_response(oidresp)
      end
    end

    get '/ids/:identity' do
      @identity = params[:identity]
      @endpoint = server_url
      erb :identity
    end

  end
end


