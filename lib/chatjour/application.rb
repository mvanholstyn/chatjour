require 'etc'
require 'set'
require 'dnssd'

Thread.abort_on_exception = true
 
module Chatjour
  class Application
    ChatService = Struct.new(:name, :host, :port, :description)
    
    def self.run(*args)
      new(*args).run
    end

    def initialize(*args)
      @port, @username, @in, @out = 1323, Etc.getlogin, STDIN, STDOUT
    end
    
    def run
      register
      listen
    end
    
    def register
      tr = DNSSD::TextRecord.new
      tr['description'] = @username
      
      DNSSD.register(@username, "_chat._tcp", 'local', @port, tr.encode) do |rr|
        @out.puts "Registered #{@username} on port #{@port}. Starting Chatjour."
      end
    end
    
    def listen
      @in.each do |command|
        @out.puts "Got: #{command}"
      end
    end
    
    # def discover(timeout = 20)
    #   waiting_thread = Thread.current
    # 
    #   dns = DNSSD.browse "_chat._tcp" do |reply|
    #     DNSSD.resolve reply.name, reply.type, reply.domain do |resolve_reply|
    #       service = ChatService.new(reply.name,
    #                                resolve_reply.target,
    #                                resolve_reply.port,
    #                                resolve_reply.text_record['description'].to_s)
    #       begin
    #         yield service
    #       rescue Done
    #         waiting_thread.run
    #       end
    #     end
    #   end
    # 
    #   puts "Gathering for up to #{timeout} seconds..."
    #   sleep timeout
    #   dns.stop
    # end
    # 
    # def users
    #   list = Set.new
    #   discover { |obj| list << obj }
    #   list
    # end
  end
end
