module Chatjour
  class Status
    BONJOUR_PORT = 5001

    def initialize
      @status, @message = "Available", nil
    end

    def start
      text_record = DNSSD::TextRecord.new
      text_record["status"]  = @status
      text_record["message"] = @message
      @broadcast = DNSSD.register(Etc.getlogin, "_chat._tcp", 'local', BONJOUR_PORT, text_record.encode) do |resolve_reply|; end
    end
    
    def stop
      @broadcast.stop
    end
  end
end