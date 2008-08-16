module Chatjour
  class BuddyList
    attr_reader :users
    
    def initialize
      @users = []
    end
    
    def add(new_user)
      if user = @users.detect { |u| u.name == new_user.name }
        @users.delete(user)
      end
      @users << new_user
    end
    
    def start
      @browser = DNSSD.browse("_chat._tcp") do |reply|
        DNSSD.resolve reply.name, reply.type, reply.domain do |resolve_reply|
          add(
            User.new(reply.name, resolve_reply.text_record['status'], resolve_reply.text_record['message'], resolve_reply.target, resolve_reply.port)
          )
        end
      end
    end
    
    def stop
      @browser.stop
    end
  end
end
