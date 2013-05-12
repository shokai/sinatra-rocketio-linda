module Sinatra
  module RocketIO
    module Linda

      def linda=(options)
        Linda.options = options
      end

      def linda
        Linda.options
      end

      def self.default_options
        {
          :expire_check => [60, lambda{|v| v.kind_of? Fixnum and v > 0 }]
        }
      end

      def self.options
        @@options ||= (
                       opts = {}
                       default_options.each do |k,v|
                         opts[k] = v[0]
                       end
                       opts
                       )
      end

      def self.options=(opts)
        @@options = {}
        opts.each do |k,v|
          k = k.to_sym
          unless default_options.include? k
            STDERR.puts "!! Sinatra::RocketIO::Linda setting - \"#{k}\" is not valid key"
          else
            unless default_options[k][1].call(v)
              default = default_options[k][0]
              STDERR.puts "!! Sinatra::RocketIO::Linda setting - \"#{k} => #{v}\" is not valid. set default \"#{k} => #{default}\""
              @@options[k] = default
            else
              @@options[k] = v
            end
          end
        end
        default_options.each do |k, v|
          @@options[k] = v[0] unless @@options.include? k
        end
        @@options
      end

    end
  end
end
