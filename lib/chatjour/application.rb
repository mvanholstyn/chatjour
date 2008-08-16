require 'etc'
require 'set'
require 'yaml'
require 'dnssd'

Thread.abort_on_exception = true
 
module Chatjour
  class Application
    def self.run(*args)
      new(*args).run
    end

    def initialize(*args)
      @port, @username, @messages, @in, @out = 1323, Etc.getlogin, [], STDIN, STDOUT
    end
    
    def run
      register
      listen
    end
    
    def register
      text_record = DNSSD::TextRecord.new
      text_record["chats"] = @messages.to_yaml
      
      @service.stop if @service
      @service = DNSSD.register(@username, "_chat._tcp", 'local', @port, text_record.encode) do |resolve_reply|
        # @out.puts "Registered #{@username} on port #{@port}. Starting Chatjour."
      end
    end
    
    def listen
      @in.each do |input|
        command, arguments = input.strip.split(" ", 2)
        arguments ||= []
        # @out.puts "Got: #{command} with #{arguments.inspect}"
        send(command, *arguments)
      end
    end
    
    def say(message)
      @messages << message
      register
    end
    
    def tell(username, message)
      
    end
    
    def users
      @out.puts *user_list
    end
    
    ChatService = Struct.new(:name, :host, :port, :chats)
    class Done < RuntimeError; end
    
    def discover(timeout = 5)
      waiting_thread = Thread.current
    
      dns = DNSSD.browse "_chat._tcp" do |reply|
        DNSSD.resolve reply.name, reply.type, reply.domain do |resolve_reply|
          service = ChatService.new(reply.name,
                                   resolve_reply.target,
                                   resolve_reply.port,
                                   YAML.load(resolve_reply.text_record['chats'].to_s))
          begin
            yield service
          rescue Done
            waiting_thread.run
          end
        end
      end
    
      puts "Gathering for up to #{timeout} seconds..."
      sleep timeout
      dns.stop
    end
    
    def user_list
      list = Set.new
      discover { |obj| list << obj }
      list
    end
  end
end
