require 'rubygems'
require 'bundler'
Bundler.setup
Bundler.require :default

users = {}



 Warden::OpenID.configure do |config|
   config.required_fields = 'email'
   config.optional_fields = %w(nickname fullname)

   config.user_finder do |response|
     fields = OpenID::SReg::Response.from_success_response(response)
     p fields
   end
 end
 
helpers do
  def warden
    env['warden']
  end
end

get '/' do
  haml <<-'HAML'
%p#notice= flash[:notice]
%p#error= flash[:error]

- if warden.authenticated?
  %p
    Welcome #{warden.user}!
    %a(href='/signout') Sign out
- else
  %form(action='/signin' method='post')
    %p
      %label
        OpenID:
        %input(type='text' name='openid_identifier')
      %input(type='submit' value='Sign in')
  HAML
end

post '/signin' do
  warden.authenticate!
  flash[:notice] = 'You signed in'
  redirect '/'
end

get '/signout' do
  warden.logout(:default)
  flash[:notice] = 'You signed out'
  redirect '/'
end

post '/unauthenticated' do
  if openid = env['warden.options'][:openid]
    # OpenID authenticate success, but user is missing
    # (Warden::OpenID.user_finder returns nil)
    session[:identity_url] = openid[:response].identity_url
    redirect '/register'
  else
    # OpenID authenticate failure
    flash[:error] = warden.message
    redirect '/'
  end
end

get '/register' do
  haml <<-'HAML'
%form(action='/signup' method='post')
  %p
    %label
      Name:
      %input(type='text' name='name')
    %input(type='submit' value='Sign up')
  HAML
end

post '/signup' do
  if (name = params[:name]).empty?
    redirect '/register'
  else
    users[session.delete(:identity_url)] = name
    warden.set_user name
    flash[:notice] = 'You signed up'
    redirect '/'
  end
end
