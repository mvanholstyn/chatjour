require 'dnssd'
require 'etc'
require 'ipaddr'

module Chatjour
  class Application
    BONJOUR_PORT = 5001
    MULTICAST_ADDRESS = "225.4.5.6"
    MULTICAST_PORT = 5000
    MULTICAST_INTERFACE = "0.0.0.0"

    def say(msg)
      begin
        socket = UDPSocket.open
        socket.setsockopt(Socket::IPPROTO_IP, Socket::IP_TTL, [1].pack('i'))
        socket.send(msg, 0, MULTICAST_ADDRESS, MULTICAST_PORT)
      ensure
        socket.close 
      end
    end
    
    def receive
      messages = []
      loop do
        messages << @incoming_socket.recvfrom_nonblock(1024).first
      end
      messages
    rescue Errno::EAGAIN
      messages
    end
  
    def start
      broadcast
      listen_for_incoming_messages
    end
    
  private
    def broadcast
      text_record = DNSSD::TextRecord.new
      @service = DNSSD.register(Etc.getlogin, "_chat._tcp", 'local', BONJOUR_PORT, text_record.encode) do |resolve_reply|; end
    end
    
    def listen_for_incoming_messages
      @incoming_socket = UDPSocket.new
      ip = IPAddr.new(MULTICAST_ADDRESS).hton + IPAddr.new(MULTICAST_INTERFACE).hton
      @incoming_socket.setsockopt(Socket::IPPROTO_IP, Socket::IP_ADD_MEMBERSHIP, ip)
      @incoming_socket.bind(Socket::INADDR_ANY, MULTICAST_PORT)
    end
  end
end