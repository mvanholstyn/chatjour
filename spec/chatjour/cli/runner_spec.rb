require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Chatjour::Cli::Runner do
  it "creates a controller with an application and a cli view" do
    pending "How can I test this?"
    view, app = Chatjour::Cli::View.stub!(:new).and_return("view"), Chatjour::Application.stub!(:new).and_return("app")
    controller = stub("controller", :process => nil)
    Chatjour::Controller.should_receive(:new).with("app", "view").and_return(controller)
    Chatjour::Cli::Runner.start
  end
end
