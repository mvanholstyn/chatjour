require 'dnssd'
require 'ipaddr'

module Chatjour
  Message = Struct.new(:body, :user)

  class Application
    attr_reader :broadcaster, :buddy_list, :messenger
    
    def initialize
      @broadcaster = Broadcaster.new
      @buddy_list = BuddyList.new
      @messenger = Messenger.new(@buddy_list)
    end

    def start
      @broadcaster.start
      @buddy_list.start
      @messenger.start
      if block_given?
        yield self
        stop
      end
    end
    
    def stop
      @broadcaster.stop
      @buddy_list.stop
      @messenger.stop
    end
  end
end