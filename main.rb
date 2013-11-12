require 'rubygems'
require 'sinatra'
require 'pry'

set :sessions, true

get '/' do
  "Hello World"
end


get '/game' do
  erb :game
end

post '/entername' do
  puts params['username']
end

get '/nested' do
  erb :"user/nested"
end

get '/re' do
  redirect '/'
end

