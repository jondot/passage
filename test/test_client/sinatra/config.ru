require 'app'

use Rack::Session::Cookie
use Rack::OpenID

use Warden::Manager do |manager|
  manager.default_strategies :openid
  manager.failure_app = Sinatra::Application
end

use Rack::Flash
run Sinatra::Application
