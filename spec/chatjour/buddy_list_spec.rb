require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Chatjour::BuddyList do
  it "starts gathering users over bonjour" do
    browser = stub("browser")
    
    text_record = stub("text_record")
    text_record.should_receive(:[]).with("status").and_return("Away")
    text_record.should_receive(:[]).with("message").and_return("taking a nap")
    
    reply = mock("reply", :name => "name", :type => "type", :domain => "domain")
    DNSSD.should_receive(:browse).with("_chat._tcp").and_yield(reply).and_return(browser)
    resolve_reply = mock("reply", :target => "target", :port => "port", :text_record => text_record)
    DNSSD.should_receive(:resolve).with(reply.name, reply.type, reply.domain).and_yield(resolve_reply)
    
    buddy_list = Chatjour::BuddyList.new
    buddy_list.start
    buddy_list.users.should == [Chatjour::User.new("name", "Away", "taking a nap", "target", "port")]
  end

  it "stops gathering users over bonjour" do
    browser = stub("browser")
    browser.should_receive(:stop)
    DNSSD.stub!(:browse).and_return(browser)
    buddy_list = Chatjour::BuddyList.new
    buddy_list.start
    buddy_list.stop
  end
  
  it "replaces user in buddy list of attributes change" do
    browser = stub("browser")
    DNSSD.stub!(:browse).and_return(browser)
    
    buddy_list = Chatjour::BuddyList.new
    buddy_list.start
    buddy_list.add(Chatjour::User.new("name", "Away", "taking a nap", "target", "port"))
    buddy_list.add(Chatjour::User.new("name", "Available", "", "target", "port"))
    buddy_list.users.should == [Chatjour::User.new("name", "Available", "", "target", "port")]
  end
  
  it "can lookup a user from their IP address" do
    buddy_list = Chatjour::BuddyList.new
    buddy_list.start
    mark = Chatjour::User.new("name", "Away", "taking a nap", "1.2.3.4", "60")
    zach = Chatjour::User.new("name", "Available", "", "5.6.7.8", "70")
    buddy_list.add(mark)
    buddy_list.add(zach)
    Socket.stub!(:getaddrinfo).and_return([[nil, nil, nil,"5.6.7.8"]])
    
    buddy_list.lookup('5.6.7.8').should == zach
  end
  
  it "should remove users when they stop broadcasting"
end