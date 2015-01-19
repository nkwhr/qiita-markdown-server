require 'bundler'
require 'find'

Bundler.setup
Bundler.require

ENV['RACK_ENV'] = 'test'

%w(./config/initializers ./lib).each do |load_path|
  Find.find(load_path) { |f| require f if f.match(/\.rb$/) }
end

require 'rspec'
require 'rack/test'
require_relative '../qiita_markdown_server.rb'

def app
  QiitaMarkdownServer
end

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
end
