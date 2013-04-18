module Sinatra
  module RocketIO
    module Linda

      def self.javascript(*js_file_names)
        js_file_names = ['linda.js']
        js = ''
        js_file_names.each do |i|
          File.open(File.expand_path "../js/#{i}", File.dirname(__FILE__)) do |f|
            js += f.read+"\n"
          end
        end
        js
      end

    end
  end
end
