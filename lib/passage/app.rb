require 'sinatra/reloader'
require 'openid'
require 'openid/consumer/discovery'
require 'openid/extensions/sreg'
require 'openid/extensions/pape'
require 'openid/store/filesystem'
require 'yaml'

module Passage
  class App < Sinatra::Base
    include OpenID::Server

    CHECK_ID_REQ_K = "__passage_ckid"

    set :logging, true
    configure(:development) do
      register Sinatra::Reloader
    end

    [:post, :get].each do |meth| 
      send meth, '/' do
        oidreq = get_oid_from_params_or_session(params)
        return "This is an OpenID server endpoint." unless oidreq

        oidresp = nil
        if oidreq.kind_of?(CheckIDRequest)
          use_when_not_authorized(oidreq)

          identity = oidreq.identity
          must_be_authorized!(identity, oidreq.trust_root)
          oidresp = create_positive_assertion(oidreq, identity)
        else
          oidresp = server.handle_request(oidreq)
        end

        handle_response(oidresp)
      end
    end

    get '/:identity' do
      @identity = params[:identity]
      @endpoint = server_url
      erb :identity
    end

  private
    def must_be_authorized!(id, root)
      true
    end

    def add_sreg(oidreq, oidresp, identity)
      sregreq = OpenID::SReg::Request.from_openid_request(oidreq)
      return if sregreq.nil?

      ym = YAML::load_file(settings.ids_file)
      return if ym.nil? || ym[identity].nil?
      
      puts "** sending out #{ym[identity]}" # todo: proper log
     
      sregresp = OpenID::SReg::Response.extract_response(sregreq, ym[identity])
      oidresp.add_extension(sregresp)
    end

    def create_positive_assertion(oidreq, identity)
      oidresp = oidreq.answer(true, nil, identity)
      add_sreg(oidreq, oidresp, identity)
      oidresp
    end

    def get_oid_from_params_or_session(params)
      begin
        oidreq = server.decode_request(params)
      rescue ProtocolError => e
        oidreq = session[CHECK_ID_REQ_K]
        session[CHECK_ID_REQ_K] = nil
      end
      oidreq
    end

    def use_when_not_authorized(oidreq)
      session[CHECK_ID_REQ_K] = oidreq
    end

    def handle_response(oidresp)
      if oidresp.needs_signing
        signed_response = server.signatory.sign(oidresp)
      end
      web_response = server.encode_response(oidresp)

      case web_response.code
        when HTTP_REDIRECT
          redirect web_response.headers['location']
        else
          web_response.body
      end
    end

    def server
      if @server.nil?
        dir = Pathname.new(".").join('db').join('openid-store')
        store = OpenID::Store::Filesystem.new(dir)
        @server = Server.new(store, server_url)
      end
      return @server
    end

    def server_url
      "#{request.scheme}://#{request.host}:#{request.port}/"
    end
  end
end
