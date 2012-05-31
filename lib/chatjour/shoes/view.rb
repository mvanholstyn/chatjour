module Chatjour
  module Shoes
    class View
      def initialize(options = {})
      end
      
      def write(output)
      end
      
      def receive
      end
      
      def display_users(users)
        write "Available Users:"
        users.each do |user|
          write "  #{[user.name, user.status, user.message].delete_if { |u| u.empty? }.join(' - ')}"
        end
      end
      
      def display_messages(messages)
        messages.each do |message|
          write "#{message.user.name}: #{message.body}"
        end
      end

      def display_help
        write <<-EOHELP
Available Commands:
  /help
  /users
  /available [message]
  /away [message]
  /invisible
  /visible
  /username message
  message
EOHELP
      end
    end
  end
end