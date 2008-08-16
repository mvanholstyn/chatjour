require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Chatjour::Controller do
  
  it "can process a simple message" do
    app = mock("app")
    app.should_receive(:say).with("hello!")
    
    controller = Chatjour::Controller.new(app)
    controller.process "hello!"
  end
  
  it "can process a private message" do
    app = mock("app")
    app.should_receive(:tell).with("mark", "hello!")
    
    controller = Chatjour::Controller.new(app)
    controller.process "/mark hello!"    
  end
  
  it "can process a request for users" do
    app = mock("app")
    app.should_receive(:users).and_return([
      Chatjour::User.new("mark", "xena", "11"),
      Chatjour::User.new("zach", "elijah", "12")
    ])
    
    controller = Chatjour::Controller.new(app)
    controller.process "/users"
  end
  
end
