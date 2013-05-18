require "linda"

module Sinatra
  module RocketIO
    module Linda
      # use on-memory TupleSpace from linda gem (https://rubygems.org/gems/linda)
      class TupleSpace < ::Linda::TupleSpace
      end
    end
  end
end
