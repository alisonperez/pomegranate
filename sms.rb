require 'rubygems'
require 'sinatra'
require 'rest-client'
require 'cgi'

get '/received_ghana_may_2013' do
  RestClient.post "https://docs.google.com/forms/d/1gth6LVg8fQXs8oWvV_4dw2u767Z-XNxWuHLX8oyN0Yw/formResponse",
    "entry.980814057" => params["phone"],
    "entry.191252353" => params["text"]
end

get '/log_sent_message' do
  response['Access-Control-Allow-Origin'] = '*'
  File.open("/var/www/pomegranate/sent_message.log", 'a') do |file| 
    file.write("#{Time.now.to_s}: #{params['phone']} -> #{params['text']}\n")
  end
  "#{Time.now.to_s}: #{params['phone']} -> #{params['text']}\n"
end

get '/log' do
  response['Access-Control-Allow-Origin'] = '*'
  IO.read("/var/www/pomegranate/sent_message.log").split("\n").reverse().join("<br/>")
end
