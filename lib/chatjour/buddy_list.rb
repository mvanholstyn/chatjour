require 'set'

module Chatjour
  class BuddyList
    attr_reader :users
    
    def initialize
      @users = Set.new
    end
    
    def start
      @browser = DNSSD.browse("_chat._tcp") do |reply|
        DNSSD.resolve reply.name, reply.type, reply.domain do |resolve_reply|
          @users << User.new(reply.name, resolve_reply.text_record['status'], resolve_reply.text_record['message'], resolve_reply.target, resolve_reply.port)
        end
      end
    end
    
    def stop
      @browser.stop
    end
  end
end
