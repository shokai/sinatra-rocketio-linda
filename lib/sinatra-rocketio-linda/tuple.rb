require "linda"

module Sinatra
  module RocketIO
    module Linda
      # use linda gem (https://rubygems.org/gems/linda)
      class Tuple < ::Linda::Tuple

        attr_reader :from
        def initialize(data, opts={})
          @from = opts[:from] if opts.kind_of? Hash
          super data, opts
        end

      end
    end
  end
end
