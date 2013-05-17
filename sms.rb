require 'rubygems'
require 'sinatra'
require 'rest-client'
require 'moneta'
require 'json'
require 'pony'

# Create a simple file store
$database = Moneta.new(:File, :dir => 'database')


$tunnel_server = 'http://localhost'

set :enviroment, :development

def post_to_google(configuration,params)
  options = {}
  options[configuration["google_spreadsheet_phone_parameter"]] = params[:phone]
  options[configuration["google_spreadsheet_text_parameter"]] = params[:text]
  options[configuration["google_spreadsheet_sent_or_received_parameter"]] = params[:sent_or_received]
  puts configuration.inspect
  RestClient.post configuration["google_spreadsheet_url"], options
end

get '/receive/:port' do |port|
  params[:sent_or_received] = "received"
  post_to_google($database[port], params)
end

def send_to_phone(port,params)
  RestClient.get "#{$tunnel_server}:#{port}/sendsms", {:params => {:phone => params[:phone], :text => params[:text]}}
end

get '/send/:port' do |port|
  params[:sent_or_received] = "sent"
  post_to_google($database[port], params)
  send_to_phone(port, params)
end

get '/send_via_ssh/:port' do |port|
  params[:sent_or_received] = "sent"
  post_to_google($database[port], params)
  send_to_phone(port, params)
end

get '/send_via_email/:port' do |port|
  params[:sent_or_received] = "sent"
  post_to_google($database[port], params)
  Pony.mail(:to => 'pomegranate.ictedge@gmail.com', :from => 'pomegranate@sms.ictedge.org', :subject => params[:phone], :body => params[:text], :via => :smtp)
end

get '/gateway_status/:port' do |port|
  begin
    RestClient.get("#{$tunnel_server}:#{port}")
  rescue => e
    return e.to_s
    return "unavailable" if e.to_s.match(/Connection refused/)
  end
  return "available"
end

def new_port
  puts $database["9090"]
  while true do
    port = rand(9999)
    next if port < 1000 or $database.key?(port)
    return port.to_s
  end
end

get '/new/port' do
  new_port()
end

post '/extract_configuration' do
  RestClient.get(params["url"]).scan(/(entry\.\d+)/).flatten.to_json
end

get '/configuration/:port' do |port|
  content_type 'application/json'
  $database[port].to_json
end

post '/update_database' do
  $database[params["port"]] = JSON.parse(params.to_json) #weird hack
  "success"
end
