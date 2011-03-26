require 'helper'
require 'passage/identities'
require 'minitest/autorun'

class TestIdentities < MiniTest::Unit::TestCase
  def test_sanity
    h = { 
      /http:\/\/(.*)\.org\/(\d*)/ => { :email => 'joe@#{$1}.com', :phone => '972-#{$2}'},
      "johnnyb" => { :email => 'joe@#{$1}.com'}
    }
    ids = Identities.new h

    assert_equal "joe@google.com", ids["http://google.org/5551234"][:email]
    assert_equal "joe@google.com", ids["http://google.org/5551234"][:email]
    assert_equal "972-5551234", ids["http://google.org/5551234"][:phone]

    assert_equal nil, ids["http://microsoft.org"]
    assert_equal 'joe@#{$1}.com', ids["johnnyb"][:email]
  end

  def test_integration
    ids = Identities.new YAML::load_file('integration.yml')
    p ids
    p ids["http://localhost:4567/ids/pookie"] 
    assert_equal "pookie@foo.org", ids["http://localhost:4567/ids/pookie"]['email']
    assert_equal "pookie", ids["http://localhost:4567/ids/pookie"]['nickname']

  end
end
