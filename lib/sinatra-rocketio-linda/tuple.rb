module Sinatra
  module RocketIO
    module Linda

      class Tuple
        attr_reader :data, :type, :expire_at
        def initialize(data, opts={})
          unless [Array, Hash].include? data.class
            raise ArgumentError, 'argument must be instance of Array or Hash'
          end
          @data = data
          @type = data.class
          @expire_at = Time.now+(opts[:expire] || 300)
        end

        def match?(target)
          raise ArgumentError, 'argument must be instance of Tuple' unless target.kind_of? self.class
          return false if @type != target.type
          if @type == Array
            return false if @data.length > target.data.length
            @data.each_with_index do |v,i|
              return false if target.data[i] != v
            end
            return true
          elsif @type == Hash
            @data.each do |k,v|
              return false if target.data[k] != v
            end
            return true
          end
          false
        end

        def to_s
          @data.to_s
        end
      end

    end
  end
end
