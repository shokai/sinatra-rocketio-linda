module Sinatra
  module RocketIO
    module Linda

      def self.registered(app)
        app.helpers Sinatra::RocketIO::Linda::Helper

        app.get '/rocketio/linda.js' do
          content_type 'application/javascript'
          @js ||= ERB.new(::Sinatra::RocketIO::Linda.javascript).result(binding)
        end
      end

    end
  end
end
