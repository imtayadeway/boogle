require 'rack/test'
require 'json'
require File.expand_path("../../app", __FILE__)

RSpec.configure do |c|
  c.include Rack::Test::Methods
end
