module Sinatra
  module RocketIO
    module Linda

      class Tuple
        attr_reader :data, :type
        def initialize(data)
          unless [Array, Hash].include? data.class
            raise ArgumentError, 'argument must be instance of Array or Hash'
          end
          @data = data
          @type = data.class
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
      end

      class TupleSpace
        include Enumerable
        def initialize
          @tuples = Array.new
        end

        def each(&block)
          @tuples.each do |tp|
            yield tp
          end
        end

        def size
          @tuples.size
        end

        def write(tuple)
          tuple = Tuple.new tuple unless tuple.kind_of? Tuple
          @tuples.unshift tuple
          tuple
        end

        def read(tuple)
          tuple = Tuple.new tuple unless tuple.kind_of? Tuple
          @tuples.each do |t|
            return t if tuple.match? t
          end
        end

        def take(tuple)
          return unless tp = read(tuple)
          @tuples.delete tp
        end
      end

    end
  end
end
