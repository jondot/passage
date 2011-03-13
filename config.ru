$:.unshift File.join(File.dirname(__FILE__), *%w[lib])

require 'rubygems'
require 'bundler/setup'

require 'passage'
require 'passage/app'

run Passage::App

