require 'sinatra/base'

module Passage
  module OpenIDHelpers
    include ::OpenID::Server    

    def openid_positive_assertion(oidreq, identity, details)
      oidresp = oidreq.answer(true, nil, identity)
      add_sreg(oidreq, oidresp, identity, details)
      oidresp
    end

    def openid_response(oidresp)
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

  private
    def add_sreg(oidreq, oidresp, identity, details)
      return if details.nil?
      sregreq = OpenID::SReg::Request.from_opsetenid_request(oidreq)
      sregresp = OpenID::SReg::Response.extract_response(sregreq, identities[identity])
      oidresp.add_extension(sregresp)
    end


  end
  
  Sinatra.helpers OpenIDHelpers
end

