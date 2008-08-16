require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Chatjour::Application do
  before(:each) do
    @broadcast = stub("broadcast", :stop => nil)
    DNSSD.stub!(:register).and_return(@broadcast)
    
    @browser = mock("browser", :stop => nil)
    DNSSD.stub!(:browse).and_return(@browser)
  end

  it "can send chat messages" do
    socket = mock("socket", :null_object => true)
    UDPSocket.stub!(:open).and_return(socket)
    socket.should_receive(:send).with("Hello world", anything, anything, anything)
    socket.should_receive(:close)
    Chatjour::Application.new.start do |app|
      app.say "Hello world"
    end
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
    Chatjour::Application.new.start do |app|
      app.receive.should == ["Hello world"]
    end
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
    Chatjour::Application.new.start do |app|
      app.receive.should == ["Hello world", "Bye again", "Hello again"]
    end
  end

  it "receives nothing when there is nothing there to receive" do
    socket = mock("socket", :null_object => true)
    UDPSocket.stub!(:new).and_return(socket)
    socket.stub!(:recvfrom_nonblock).and_raise(Errno::EAGAIN)
    Chatjour::Application.new.start do |app|
      app.receive.should == []
    end
  end
  
  it "starts listening for messages right away" do
    socket = mock("socket", :null_object => true)
    UDPSocket.should_receive(:new).and_return(socket)    
    Chatjour::Application.new.start do |app|; end
  end

  it "broadcasts itself on the network right away" do
    text_record = DNSSD::TextRecord.new
    DNSSD.should_receive(:register).with(
      Etc.getlogin, 
      "_chat._tcp", 
      'local', 
      Chatjour::Application::BONJOUR_PORT, 
      text_record.encode
    ).and_return(@broadcast)
    Chatjour::Application.new.start do |app|; end
  end
  
  it "can grab a list of users" do
    reply = mock("reply", :name => "name", :type => "type", :domain => "domain")
    DNSSD.should_receive(:browse).with("_chat._tcp").and_yield(reply).and_return(@browser)
    resolve_reply = mock("reply", :name => "name", :target => "target", :port => "port")
    DNSSD.should_receive(:resolve).with(reply.name, reply.type, reply.domain).and_yield(resolve_reply)
    
    Chatjour::Application.new.start do |app|
      app.users.should == Set.new([Chatjour::User.new("name", "target", "port")])
    end
  end
  
  it "can send private message"
  
  it "can receive private messages"
  
end