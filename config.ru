$:.unshift File.join(File.dirname(__FILE__), *%w[lib])

require 'rubygems'
require 'bundler/setup'

require 'passage'
require 'passage/app'

Passage::App.configure!({})
run Passage::App

