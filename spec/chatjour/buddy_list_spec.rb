require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Chatjour::BuddyList do
  it "can grab a list of users" do
    reply = mock("reply", :name => "name", :type => "type", :domain => "domain")
    DNSSD.should_receive(:browse).with("_chat._tcp").and_yield(reply).and_return(@browser)
    resolve_reply = mock("reply", :target => "target", :port => "port")
    DNSSD.should_receive(:resolve).with(reply.name, reply.type, reply.domain).and_yield(resolve_reply)
    
    Chatjour::Application.new.start do |app|
      app.users.should == Set.new([Chatjour::User.new("name", "target", "port")])
    end
  end
  
  it "stops broadcasting via DNSSD" do
    browser = stub("browser")
    DNSSD.stub!(:browse).and_return(browse)
    browse.should_receive(:stop)
    buddy_list = Chatjour::BuddyList.new
    buddy_list.start
    buddy_list.stop
  end
end