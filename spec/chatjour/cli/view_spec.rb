require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Chatjour::Cli::View do
  it "receives input" do
    input = stub("input")
    input.stub!(:read_nonblock).and_return("/help\n")

    view = Chatjour::Cli::View.new(:input => input)
    view.receive.should == "/help"
  end
  
  it "receives no input" do
    input = stub("input")
    input.stub!(:read_nonblock).and_raise(Errno::EAGAIN)

    view = Chatjour::Cli::View.new(:input => input)
    view.receive.should be_nil
  end
  
  it "displays users" do
    output = StringIO.new
    view = Chatjour::Cli::View.new(:output => output)
    users = [
      stub("user", :name => "mvanholstyn", :status => "Away", :message => "taking a nap"),
      stub("user", :name => "zdennis", :status => "Available", :message => "")
    ]
    view.display_users(users)
    output.string.should == "\tmvanholstyn - Away - taking a nap\n\tzdennis - Available\n"
  end

  it "displays messages" do
    output = StringIO.new
    view = Chatjour::Cli::View.new(:output => output)
    messages = [
      stub("message", :body => "How is everyone?"),
      stub("message", :body => "I am good.")
    ]
    view.display_messages(messages)
    output.string.should == "Message: How is everyone?\nMessage: I am good.\n"
  end

  it "displays help" do
    output = StringIO.new
    view = Chatjour::Cli::View.new(:output => output)
    view.display_help
    output.string.should == "\t/users\n\t/help\n\t/username message\n\tmessage\n"
  end
end
