require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Chatjour::Application do
  before(:each) do
    @broadcaster = stub("broadcaster", :start => nil, :stop => nil)
    Chatjour::Broadcaster.stub!(:new).and_return(@broadcaster)

    @buddy_list = stub("buddy list", :start => nil, :stop => nil, :users => [])
    Chatjour::BuddyList.stub!(:new).and_return(@buddy_list)

    @messenger = stub("messenger", :start => nil, :stop => nil)
    Chatjour::Messenger.stub!(:new).and_return(@messenger)
  end

  it "starts/stops a broadcaster" do
    @broadcaster.should_receive(:start)
    @broadcaster.should_receive(:stop)
    Chatjour::Application.new.start do |app|; end
  end
  
  it "starts/stops a buddy list" do
    @buddy_list.should_receive(:start)
    @buddy_list.should_receive(:stop)
    Chatjour::Application.new.start do |app|; end
  end
  
  it "starts/stops a messenger" do
    @messenger.should_receive(:start)
    @messenger.should_receive(:stop)
    Chatjour::Application.new.start do |app|; end
  end
end