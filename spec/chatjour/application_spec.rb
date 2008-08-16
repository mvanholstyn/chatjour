require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Chatjour::Application do
  before(:each) do
    @browser = mock("browser", :stop => nil)
    DNSSD.stub!(:browse).and_return(@browser)
  end

  it "can send chat messages" do
    socket = mock("socket", :null_object => true)
    UDPSocket.stub!(:open).and_return(socket)
    socket.should_receive(:send).with(
      "Hello world", 
      anything, 
      Chatjour::Application::MULTICAST_ADDRESS, 
      Chatjour::Application::MULTICAST_PORT
    )
    socket.should_receive(:close)
    Chatjour::Application.new.start do |app|
      app.say "Hello world"
    end
  end
  
  it "can send private message" do
    reply = mock("reply", :name => "mark", :type => "type", :domain => "domain")
    DNSSD.should_receive(:browse).with("_chat._tcp").and_yield(reply).and_return(@browser)
    resolve_reply = mock("reply", :target => "MarksTargetAddress", :port => "port")
    DNSSD.should_receive(:resolve).with(reply.name, reply.type, reply.domain).and_yield(resolve_reply)

    socket = mock("socket", :null_object => true)
    UDPSocket.stub!(:open).and_return(socket)
    socket.should_receive(:send).with(
      "howdy!",
      anything,
      "MarksTargetAddress", 
      Chatjour::Application::MULTICAST_PORT
    )

    Chatjour::Application.new.start do |app|
      app.tell "mark", "howdy!"
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
      app.receive.should == [Chatjour::Message.new("Hello world", nil)]
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
      app.receive.should == [
        Chatjour::Message.new("Hello world", nil),
        Chatjour::Message.new("Bye again", nil),
        Chatjour::Message.new("Hello again", nil)
      ]
    end
  end
  
  it "needs to receive messages with user attached"

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
end