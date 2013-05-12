require "sinatra/rocketio/linda/version"
require "sinatra-rocketio-linda/helper"
require "sinatra-rocketio-linda/javascript"
require "sinatra-rocketio-linda/tuple"
require "sinatra-rocketio-linda/tuplespace"
require "sinatra-rocketio-linda/linda"
require "sinatra-rocketio-linda/application"

module Sinatra
  module RocketIO
    module Linda
    end
  end
  register Sinatra::RocketIO::Linda
end
