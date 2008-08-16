module Chatjour
  class Broadcaster
    PORT = 5001
    
    attr_accessor :status, :message
    
    def initialize
      @status, @message = "Available", nil
    end
    
    def away(message = nil)
      @status = "Away"
      @message = message
      restart
    end
    
    def available(message = nil)
      @status = "Available"
      @message = message
      restart
    end
    
    def start
      text_record = DNSSD::TextRecord.new
      text_record['status']  = @status
      text_record['message'] = @message
      @broadcast = DNSSD.register(Etc.getlogin, "_chat._tcp", 'local', PORT, text_record.encode) do |resolve_reply|; end
    end
    
    def stop
      @broadcast.stop
    end
    
    def restart
      stop; start
    end
  end
end