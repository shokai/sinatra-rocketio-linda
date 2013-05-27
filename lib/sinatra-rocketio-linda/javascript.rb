module Sinatra
  module RocketIO
    module Linda

      def self.javascript(*js_file_names)
        js_file_names = ['linda.js', 'rocketio.js']
        js = ''
        js_file_names.each do |i|
          js += case i
                when 'rocketio.js'
                  Sinatra::RocketIO.javascript
                else
                  j = ''
                  File.open(File.expand_path "../js/#{i}", File.dirname(__FILE__)) do |f|
                    j = f.read
                  end
                  j
                end + "\n"
        end
        js
      end

    end
  end
end
