module Sinatra
  module RocketIO
    module Linda
      module Helper

        def linda_js
          "#{env['rack.url_scheme']}://#{env['HTTP_HOST']}#{env['SCRIPT_NAME']}/rocketio/linda.js"
        end

      end
    end
  end
end
