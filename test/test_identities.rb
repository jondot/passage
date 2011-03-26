require 'teststrap'
require 'passage/identities'

context "when using identities, " do
  setup do
    h = { 
      /http:\/\/(.*)\.org\/(.*)/ => { :email => 'joe@#{$1}.com', :phone => '972-#{$2}'},
      "http://localhost/ids/johnnyb" => { :email => 'joe@#{$1}.com'}
    }
    Identities.new h
  end

  context "given regex identities" do
    asserts("that capture interpolation"){ topic["http://google.org/555-1234"][:email] }.equals "joe@google.com"
    asserts("that capture interpolation does'nt overwrite config and still"){ topic["http://google.org/555-1234"][:email] }.equals "joe@google.com"
    
    asserts("that capture group 2 (phone number)"){ topic["http://google.org/555-1234"][:phone] }.equals "972-555-1234"
  end

  context "given normal identities" do
    asserts("email"){ topic["http://localhost/ids/johnnyb"][:email] }.equals 'joe@#{$1}.com'
  end

  context "given no match found" do 
    asserts("identity"){topic["foo"]}.nil
  end
end

context "when loading identities from file, " do
  setup do
    Identities.new YAML::load_file 'integration.yml'
  end 
  context "given regex identities" do
    asserts("that email"){ topic["http://localhost:4567/ids/joe"]['email'] }.equals "joe@foo.org"
    asserts("that nickname"){ topic["http://localhost:4567/ids/joe"]['nickname'] }.equals "joe"
  end

  context "given normal identities" do
    asserts("email"){ topic["http://77.127.240.49:9292/ids/foo"]['email'] }.equals 'foo@foo.org'
  end

  context "given no match found" do 
    asserts("identity"){topic["foo"]}.nil
  end
end
