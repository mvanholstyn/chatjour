require 'dnssd'
 
module Chatjour
  class Application
    def self.run(*args)
      case args.shift
        when "users"; users(*args)
        else;         help
      end
    end
    
    def self.help
      puts "Chatjour"
      puts "Chat via Bonjour/DNSSD."
      puts "\nUsage: chatjour <command> [args]"
      puts
      puts "  users"
      puts "      Lists available users."
      puts
    end
    
    def self.users(*args)
      puts "At some point, this will show you all the users."
      puts
    end
  end
end