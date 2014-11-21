require 'rubygems'
require 'bundler/setup'
Bundler.require(:default, :test, :development)

get '/hello' do
  "world"
end

get '/' do
  '<h1>Taco Bell</h1>'
end
