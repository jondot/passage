require 'sinatra/base'
module Passage
  module Auth
    module PassThrough
      module Helpers
        def auth_setup(req); end
        def auth_fetch; end
        def auth_validate!(identity, trust_root); end
      end

      def self.registered(app)
        app.helpers Auth::PassThrough::Helpers
      end
    end 

    Sinatra.register PassThrough
  end
end

