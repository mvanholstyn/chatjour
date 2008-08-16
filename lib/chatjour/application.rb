module Chatjour
  User = Struct.new(:name, :host, :port)
  Message = Struct.new(:body, :user)

  class Application
    def initialize
      @status = Status.new
      @buddy_list = BuddyList.new
      @Messenger = Messenger.new
    end
    
    def start
      @status.start
      @buddy_list.start
      @Messenger.start
    end
    
    def stop
      @status.stop
      @buddy_list.stop
      @Messenger.stop
    end
  end
end