passage
=======

Passage is an OpenID provider, which can serve several goals:

* Personal, tiny-smart-hackable, OpenID provider.
* OpenID provider test server.

Passage aims to provide a 'path through', it can be useful if any or several of these are true for you:

* You have an internal / sandboxed / restricted environment, as a test server
* You don't really care about providing your real ID to a web site.
* You wish to remain completely anonymous.
* You wish to implement your own authentication strategy (finger print, cell call)
* You wish to have full control over your identity and registration detail
* You want several identities
* .. The list goes on..

Quick Start
-----------

As a personal gem:

        $gem install passage
        $passage --ids myids.yml --auth pass_through

Or deploy it:

        $git clone https://github.com/jondot/passage
        $export PSG_IDS_FILE=myids.yml
        $cd passage
        $rackup 


Thats it!


Your identities (`identities.yml`)
----------------------------------
        $cat identities.yml.example
        'http://localhost:9292/ids/foo':
          email: foo@foo.org
        'http://77.127.240.49:9292/ids/foo':
          email: foo@foo.org
        'http://77.124.212.222:4567/ids/pookie':
          email: goo@goo.org
        !ruby/regexp /http:\/\/localhost:4567\/ids\/(.*)/:
          email: '#{$1}@foo.org'
          nickname: '#{$1}'

The one starting with `!ruby/regexp` is a proper regular expression with a capture group. The OpenID SReg fields following it (email, nickname), are using the capture group in order to have some kind of logic in them, without your intervention. You can identify these as being plain ruby interpolated strings.   
For further interest, you can read below about typical use cases for setting up identities.

Authentication Strategies
-------------------------

the `auth` folder holds _authentication strategies_. An authentication strategy answers to the following:

        def auth_setup(req); end
        def auth_fetch; end
        def auth_validate!(identity, trust_root); end

A good starting point will be to copy-paste an existing one and tweak it to your use.
Authentication strategies are **auto-discovered**, so just drop your folder in `/auth`, and configure your selected one via configuration.
An example authentication strategy would be one that would present a user/password form and store credentials at the DB. This will "upgrade" your Passage instance from a _personal_ to a full fledged OpenID server.

Here is a description of existing authentication strategies

* `pass_through` - Lets authentication always pass. No need for any credentials or so.
* `pass_phrase`  - Authentication will pass only if a proper pass phrase was specified.



Configuration
-------------
You can pass an options hash to Passage:

    Passage::App.configure! options

In it, these are the available configurations:

* `:ids_file` - location of the identities.yml file.
* `:auth` - selected authentication strategy.
* `:logger` - a logger instance

When under certain hosting providers, Passage knows to take important configuration values from your environment variables instead, by convention, these will be PSG_[uppercase config key], e.g. `PSG_IDS_FILE`.

For specifying configurations via command line run `$passage --help`




As a Personal OpenID Provider
-----------------------------
You can have your fixed identities at your domain, or even throw-away identities.

To set fixed identities in your domain, simply code them up in your `identities.yml` file and let `passage` know about it.  

Using throw-away identities can maximize your anonymity around the Web. To have throw-away identities you can specify any identity you wish in your `identities.yml` manually, or specify a smart rule as a regex identity:

      !ruby/regex /http:\/\/mydomain\.com\/ids\/(.*)/:
        email: 'myuser@gmail.com'

This will let you specify any user you wish to make up, at your domain.

As an OpenID Test Server
------------------------
Passage is great (and being used internally) for integration tests against OpenID consumers (relying parties).
Through Passage's identity configuration system, you can load up fixed identities per test scenario, or you can load identities which follow certain rules (with regex enabled identities).

As an example, you can store as fixed identities in your `dev` environment:
  
      'http://dev.com/ids/foo':
        email: foo@dev.com
  
Or, you can store the following if you have many dynamic users:

      !ruby/regex /http:\/\/dev\.com\/ids\/(.*)/:
        email: '#{$1}@dev.com'
  
This makes use of regex enabled identities, in which you specify a regex as the user identifier, and any SReg property can make use of the captures that were made.



Hacking
-------

But this is not the end. Passage is extremely flexible, and you can get a good mileage out of it. To your benefit, I've devided the points of interest into the following:

* app - any application specific flow; you'll seldom want to touch this.
* environment - any application configuration and environment setups.
* open_id - any openid related logic; you might want to fiddle with this in order to add PAPE for example.
* identities - the basic logic for identity matching; you might want to play with this in order to have random identities, for example.



Contributing to passage
=======================

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

Copyright
=========

Copyright (c) 2011 Dotan Nahum. See LICENSE.txt for
further details.

