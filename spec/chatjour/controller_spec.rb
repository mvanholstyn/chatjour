require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Chatjour::Controller do
  it "starts the app" do
    view, app = stub("view"), stub("app")
    app.should_receive(:start)
    
    Chatjour::Controller.new(app, view)
  end
  
  it "processes user input for help" do
    view, app = stub("view", :receive => "/help", :display_messages => nil), stub("app", :start => nil, :receive => [])
    view.should_receive(:display_help)
    Chatjour::Controller.new(app, view).process
  end
  
  it "processes user input for setting status as available with no message" do
    broadcaster = stub("broadcaster")
    view, app = stub("view", :receive => "/available", :display_messages => nil), stub("app", :start => nil, :receive => [], :broadcaster => broadcaster)
    broadcaster.should_receive(:available).with(nil)
    Chatjour::Controller.new(app, view).process
  end
  
  it "processes user input for setting status as available with a message" do
    broadcaster = stub("broadcaster")
    view, app = stub("view", :receive => "/available hanging out", :display_messages => nil), stub("app", :start => nil, :receive => [], :broadcaster => broadcaster)
    broadcaster.should_receive(:available).with("hanging out")
    Chatjour::Controller.new(app, view).process
  end
  
  it "processes user input for setting status as away with no message" do
    broadcaster = stub("broadcaster")
    view, app = stub("view", :receive => "/away", :display_messages => nil), stub("app", :start => nil, :receive => [], :broadcaster => broadcaster)
    broadcaster.should_receive(:away).with(nil)
    Chatjour::Controller.new(app, view).process
  end
  
  it "processes user input for setting status as away with a message" do
    broadcaster = stub("broadcaster")
    view, app = stub("view", :receive => "/away taking a nap", :display_messages => nil), stub("app", :start => nil, :receive => [], :broadcaster => broadcaster)
    broadcaster.should_receive(:away).with("taking a nap")
    Chatjour::Controller.new(app, view).process
  end

  it "processes user input for users list" do
    view, app = stub("view", :receive => "/users", :display_messages => nil), stub("app", :start => nil, :receive => [], :users => "array of users")
    view.should_receive(:display_users).with("array of users")
    Chatjour::Controller.new(app, view).process
  end
  
  it "processes user input for private message" do
    view, app = stub("view", :receive => "/mvanholstyn How are you?", :display_messages => nil), stub("app", :start => nil, :receive => [])
    app.should_receive(:tell).with("mvanholstyn", "How are you?")
    Chatjour::Controller.new(app, view).process
  end
  
  it "processes user input for public message" do
    view, app = stub("view", :receive => "How is everyone?", :display_messages => nil), stub("app", :start => nil, :receive => [])
    app.should_receive(:say).with("How is everyone?")
    Chatjour::Controller.new(app, view).process
  end
  
  it "processes received messages" do
    view, app = stub("view", :receive => nil), stub("app", :start => nil, :receive => "array of messages")
    view.should_receive(:display_messages).with("array of messages")
    Chatjour::Controller.new(app, view).process
  end
end
