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

      class TupleSpace
        include Enumerable

        def initialize
          @tuples = Array.new
          @callbacks = Array.new
        end

        def each(&block)
          @tuples.each do |tp|
            yield tp
          end
        end

        def size
          @tuples.size
        end

        DEFAULT_WRITE_OPTIONS = {
          :expire => 300
        }

        def write(tuple, opts={})
          raise ArgumentError, "options must be Hash" unless opts.kind_of? Hash
          DEFAULT_WRITE_OPTIONS.each do |k,v|
            opts[k] = v unless opts.include? k
          end
          tuple = Tuple.new tuple, opts unless tuple.kind_of? Tuple
          calleds = []
          taked = nil
          @callbacks.each do |callback|
            next unless callback[:tuple].match? tuple
            callback[:callback].call tuple
            calleds.push callback
            if callback[:type] == :take
              taked = tuple
              break
            end
          end
          calleds.each do |called|
            @callbacks.delete called
          end
          @tuples.unshift tuple unless taked
          tuple
        end

        def read(tuple, &block)
          tuple = Tuple.new tuple unless tuple.kind_of? Tuple
          @tuples.each do |t|
            if tuple.match? t
              if block_given?
                block.call t
                return
              else
                return t
              end
            end
          end
          @callbacks.push(:type => :read, :callback => block, :tuple => tuple) if block_given?
        end

        def take(tuple, &block)
          tuple = Tuple.new tuple unless tuple.kind_of? Tuple
          matched_tuple = nil
          @tuples.each do |t|
            if tuple.match? t
              matched_tuple = t
              break
            end
          end
          if matched_tuple
            @tuples.delete matched_tuple
            if block_given?
              block.call matched_tuple
            else
              return matched_tuple
            end
          else
            @callbacks.push(:type => :take, :callback => block, :tuple => tuple) if block_given?
          end
        end

        def check_expire
          expires = []
          each do |tuple|
            expires.push tuple unless tuple.expire_at > Time.now
          end
          expires.each do |tuple|
            @tuples.delete tuple
          end
        end
      end

    end
  end
end