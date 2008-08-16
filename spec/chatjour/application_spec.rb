require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Chatjour::Application do
  before(:each) do
    DNSSD.stub!(:register)
  end

  it "can send chat messages" do
    socket = mock("socket", :null_object => true)
    UDPSocket.stub!(:open).and_return(socket)
    socket.should_receive(:send).with("Hello world", anything, anything, anything)
    socket.should_receive(:close)
    Chatjour::Application.new.say "Hello world"
  end
  
  it "can receive chat messages" do
    socket = mock("socket", :null_object => true)
    UDPSocket.stub!(:new).and_return(socket)
    messages = [
      ["Hello world", stub("info")]
    ]
    socket.stub!(:recvfrom_nonblock).and_return do
      messages.shift || raise(Errno::EAGAIN)
    end
    app = Chatjour::Application.new
    app.start
    app.receive.should == ["Hello world"]
  end

  it "can receive multiple pending chat messages" do
    socket = mock("socket", :null_object => true)
    UDPSocket.stub!(:new).and_return(socket)
    messages = [
      ["Hello world", stub("info")], 
      ["Bye again", stub("info")], 
      ["Hello again", stub("info")]
    ]
    socket.stub!(:recvfrom_nonblock).and_return do
      messages.shift || raise(Errno::EAGAIN)
    end
    app = Chatjour::Application.new
    app.start
    app.receive.should == ["Hello world", "Bye again", "Hello again"]
  end

  it "receives nothing when there is nothing there to receive" do
    socket = mock("socket", :null_object => true)
    UDPSocket.stub!(:new).and_return(socket)
    socket.stub!(:recvfrom_nonblock).and_raise(Errno::EAGAIN)
    app = Chatjour::Application.new
    app.start
    app.receive.should == []
  end
  
  it "starts listening for messages right away" do
    socket = mock("socket", :null_object => true)
    UDPSocket.should_receive(:new).and_return(socket)    
    Chatjour::Application.new.start
  end

  it "broadcasts itself on the network right away" do
    text_record = DNSSD::TextRecord.new
    DNSSD.should_receive(:register).with(
      Etc.getlogin, 
      "_chat._tcp", 
      'local', 
      Chatjour::Application::BONJOUR_PORT, 
      text_record.encode
    )
    Chatjour::Application.new.start
  end
  
  it "can grab a list of users" do
    reply = mock("reply", :name => "name", :type => "type", :domain => "domain")
    browser = mock("browser")
    DNSSD.should_receive(:browse).with("_chat._tcp").and_yield(reply).and_return(browser)
    resolve_reply = mock("reply", :name => "name", :target => "target", :port => "port")
    DNSSD.should_receive(:resolve).with(reply.name, reply.type, reply.domain).and_yield(resolve_reply)
    browser.should_receive(:stop)
    
    app = Chatjour::Application.new
    app.start
    app.users.should == Set.new([Chatjour::User.new("name", "target", "port")])
  end
  
  it "can send private message"
  
  it "can receive private messages"
  
end

__END__
    User = Struct.new(:name, :host, :port)
    class Done < RuntimeError; end
  
    def discover(timeout = 5)
      # waiting_thread = Thread.current
    
      list = Set.new

      dns = DNSSD.browse "_chat._tcp" do |reply|
        DNSSD.resolve reply.name, reply.type, reply.domain do |resolve_reply|
          service = User.new(reply.name, resolve_reply.target, resolve_reply.port)
          # begin
          #   list << service
          # rescue Done
          #   waiting_thread.run
          # end
        end
      end
    
      sleep timeout
      dns.stop
      
      list
    end





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
