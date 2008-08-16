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
end
