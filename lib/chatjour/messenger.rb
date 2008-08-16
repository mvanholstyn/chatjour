module Chatjour
  class Messenger
    MULTICAST_ADDRESS = "225.4.5.6"
    MULTICAST_PORT = 5000
    MULTICAST_INTERFACE = "0.0.0.0"

    def initialize(buddy_list)
      @buddy_list = buddy_list
    end

    def say(msg)
      begin
        socket = UDPSocket.open
        socket.setsockopt(Socket::IPPROTO_IP, Socket::IP_TTL, [1].pack('i'))
        socket.send(msg, 0, MULTICAST_ADDRESS, MULTICAST_PORT)
      ensure
        socket.close 
      end
    end
    
    def tell(user, msg)
      user = @buddy_list.users.detect { |u| u.name == user }
      begin
        socket = UDPSocket.open
        socket.setsockopt(Socket::IPPROTO_IP, Socket::IP_TTL, [1].pack('i'))
        socket.send(msg, 0, user.host, MULTICAST_PORT)
      ensure
        socket.close 
      end
    end
    
    def receive
      messages = []
      loop do
        body, info = @incoming_socket.recvfrom_nonblock(1024)
        user = @buddy_list.lookup(info[3])
        messages << Message.new(body, user)
      end
    rescue Errno::EAGAIN
      messages
    end
    
    def start
      @incoming_socket = UDPSocket.new
      ip = IPAddr.new(MULTICAST_ADDRESS).hton + IPAddr.new(MULTICAST_INTERFACE).hton
      @incoming_socket.setsockopt(Socket::IPPROTO_IP, Socket::IP_ADD_MEMBERSHIP, ip)
      @incoming_socket.bind(Socket::INADDR_ANY, MULTICAST_PORT)
    end
    
    def stop
      @incoming_socket.close
    end
  end
end