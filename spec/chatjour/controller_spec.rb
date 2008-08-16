require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Chatjour::Controller do
  before(:each) do
    @broadcaster = stub("broadcaster")
    @buddy_list = stub("buddy list", :users => [])
    @messenger = stub("messenger", :receive => nil)
    @app = stub("app", :broadcaster => @broadcaster, :buddy_list => @buddy_list, :messenger => @messenger, :start => nil)
    
    @view = stub("view", :display_messages => nil, :receive => nil)
  end
  
  it "starts the app" do
    @app.should_receive(:start)
    Chatjour::Controller.new(@app, @view)
  end
  
  it "processes user input for help" do
    @view.stub!(:receive).and_return("/help")
    @view.should_receive(:display_help)
    Chatjour::Controller.new(@app, @view).process
  end
  
  it "processes user input for setting status as available with no message" do
    @view.stub!(:receive).and_return("/available")
    @broadcaster.should_receive(:available).with(nil)
    Chatjour::Controller.new(@app, @view).process
  end
  
  it "processes user input for setting status as available with a message" do
    @view.stub!(:receive).and_return("/available hanging out")
    @broadcaster.should_receive(:available).with("hanging out")
    Chatjour::Controller.new(@app, @view).process
  end
  
  it "processes user input for setting status as away with no message" do
    @view.stub!(:receive).and_return("/away")
    @broadcaster.should_receive(:away).with(nil)
    Chatjour::Controller.new(@app, @view).process
  end
  
  it "processes user input for setting status as away with a message" do
    @view.stub!(:receive).and_return("/away taking a nap")
    @broadcaster.should_receive(:away).with("taking a nap")
    Chatjour::Controller.new(@app, @view).process
  end

  it "processes user input for users list" do
    @view.stub!(:receive).and_return("/users")
    @view.should_receive(:display_users).with([])
    Chatjour::Controller.new(@app, @view).process
  end
  
  it "processes user input for private message" do
    @view.stub!(:receive).and_return("/mvanholstyn How are you?")
    @messenger.should_receive(:tell).with("mvanholstyn", "How are you?")
    Chatjour::Controller.new(@app, @view).process
  end
  
  it "processes user input for public message" do
    @view.stub!(:receive).and_return("How is everyone?")
    @messenger.should_receive(:say).with("How is everyone?")
    Chatjour::Controller.new(@app, @view).process
  end
  
  it "processes received messages" do
    @messenger.stub!(:receive).and_return([])
    @view.should_receive(:display_messages).with([])
    Chatjour::Controller.new(@app, @view).process
  end
end
