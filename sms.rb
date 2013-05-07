require 'rubygems'
require 'sinatra'
require 'rest-client'
require 'cgi'

get '/post_to_google' do
  response = RestClient.post "https://docs.google.com/forms/d/1gth6LVg8fQXs8oWvV_4dw2u767Z-XNxWuHLX8oyN0Yw/formResponse", "entry.980814057" => CGI.escape(params["phone"]) , "entry.191252353" => CGI.escape(params["text"])
  puts response.to_str
end
