require 'rubygems'
require 'sinatra'

set :environment, ENV['RACK_ENV'].to_sym
disable :run, :reload

require File.dirname(__FILE__) + "/sms.rb"

run Sinatra::Application
