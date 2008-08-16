module Chatjour
  module Cli
    class View
      def initialize(options = {})
        @input  = options[:input]  || STDIN
        @output = options[:output] || STDOUT
      end
      
      def receive
        @input.read_nonblock(1024).chop
      rescue Errno::EAGAIN
      end
      
      def display_users(users)
        users.each do |user|
          @output.puts "\t#{[user.name, user.status, user.message].delete_if { |u| u.empty? }.join(' - ')}"
        end
      end

      def display_messages(messages)
        messages.each do |message|
          @output.puts "Message: #{message.body}"
        end
      end

      def display_help
        @output.puts "\t/users", 
                     "\t/help", 
                     "\t/username message", 
                     "\tmessage"
      end
    end
  end
end