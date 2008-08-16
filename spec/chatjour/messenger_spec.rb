require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Chatjour::Messenger do
  it "can send chat messages" do
    socket = mock("socket", :null_object => true)
    UDPSocket.stub!(:open).and_return(socket)
    socket.should_receive(:send).with(
      "Hello world", 
      anything, 
      Chatjour::Messenger::MULTICAST_ADDRESS, 
      Chatjour::Messenger::MULTICAST_PORT
    )
    socket.should_receive(:close)
    buddy_list = stub("buddy list")
    messenger = Chatjour::Messenger.new(buddy_list)
    messenger.start
    messenger.say "Hello world"
    messenger.stop
  end
  
  it "can send private message" do
    socket = mock("socket", :null_object => true)
    UDPSocket.stub!(:open).and_return(socket)
    socket.should_receive(:send).with(
      "howdy!",
      anything,
      "10.0.0.1", 
      Chatjour::Messenger::MULTICAST_PORT
    )

    buddy_list = stub("buddy list", :users => [
      Chatjour::User.new("mark", "Available", nil, "10.0.0.1", 5000)
    ])
    messenger = Chatjour::Messenger.new(buddy_list)
    messenger.start
    messenger.tell "mark", "howdy!"
    messenger.stop
  end
  
  it "can receive chat messages" do
    socket = mock("socket", :null_object => true)
    UDPSocket.stub!(:new).and_return(socket)
    messages = [
      ["Hello world", stub("info", :[] => nil)]
    ]
    socket.stub!(:recvfrom_nonblock).and_return do
      messages.shift || raise(Errno::EAGAIN)
    end

    buddy_list = stub("buddy list", :users => [
      Chatjour::User.new("mark", "Available", nil, "10.0.0.1", 5000)
    ])
    messenger = Chatjour::Messenger.new(buddy_list)
    messenger.start
    messenger.receive.should == [Chatjour::Message.new("Hello world", nil)]
    messenger.stop
  end

  it "can receive multiple pending chat messages" do
    socket = mock("socket", :null_object => true)
    UDPSocket.stub!(:new).and_return(socket)
    messages = [
      ["Hello world", stub("info", :[] => nil)], 
      ["Bye again", stub("info", :[] => nil)], 
      ["Hello again", stub("info", :[] => nil)]
    ]
    socket.stub!(:recvfrom_nonblock).and_return do
      messages.shift || raise(Errno::EAGAIN)
    end
    
    buddy_list = stub("buddy list", :users => [
      Chatjour::User.new("mark", "Available", nil, "10.0.0.1", 5000)
    ])
    messenger = Chatjour::Messenger.new(buddy_list)
    messenger.start
    messenger.receive.should == [
        Chatjour::Message.new("Hello world", nil),
        Chatjour::Message.new("Bye again", nil),
        Chatjour::Message.new("Hello again", nil)
      ]
    messenger.stop
  end
  
  it "needs to receive messages with user attached"

  it "receives nothing when there is nothing there to receive" do
    socket = mock("socket", :null_object => true)
    UDPSocket.stub!(:new).and_return(socket)
    socket.stub!(:recvfrom_nonblock).and_raise(Errno::EAGAIN)

    buddy_list = stub("buddy list")
    messenger = Chatjour::Messenger.new(buddy_list)
    messenger.start
    messenger.receive.should == []
    messenger.stop
  end
  
  it "starts listening for messages right away" do
    buddy_list = stub("buddy list")
    socket = mock("socket", :null_object => true)
    UDPSocket.should_receive(:new).and_return(socket)    
    messenger = Chatjour::Messenger.new(buddy_list)
    messenger.start
    messenger.stop
  end
end