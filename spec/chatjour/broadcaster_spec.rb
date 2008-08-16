require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Chatjour::Broadcaster do
  it "starts broadcasting over bonjour" do
    broadcast = stub("broadcast")
    text_record = DNSSD::TextRecord.new
    text_record['status'] = "Available"
    text_record['message'] = nil
    DNSSD.should_receive(:register).with(
      Etc.getlogin, 
      "_chat._tcp", 
      'local', 
      Chatjour::Broadcaster::PORT, 
      text_record.encode
    ).and_return(broadcast)
    Chatjour::Broadcaster.new.start
  end
  
  it "stops broadcasting over bonjour" do
    broadcast = stub("broadcast")
    broadcast.should_receive(:stop)
    DNSSD.stub!(:register).and_return(broadcast)
    broadcaster = Chatjour::Broadcaster.new
    broadcaster.start
    broadcaster.stop
  end
  
  it "default status is Available" do
    broadcast = stub("broadcast")
    DNSSD.stub!(:register).and_return(broadcast)

    broadcaster = Chatjour::Broadcaster.new
    broadcaster.start
    broadcaster.status.should == "Available"
  end
  
  it "default message is nil" do
    broadcast = stub("broadcast")
    DNSSD.stub!(:register).and_return(broadcast)

    broadcaster = Chatjour::Broadcaster.new
    broadcaster.start
    broadcaster.message.should be_nil
  end
  
  it "can set the status to away with no message" do
    broadcast = stub("broadcast")
    DNSSD.stub!(:register).and_return(broadcast)

    broadcaster = Chatjour::Broadcaster.new
    broadcaster.start
    
    broadcast.should_receive(:stop)
    text_record = DNSSD::TextRecord.new
    text_record['status'] = "Away"
    text_record['message'] = nil
    DNSSD.should_receive(:register).with(
      Etc.getlogin, 
      "_chat._tcp", 
      'local', 
      Chatjour::Broadcaster::PORT, 
      text_record.encode
    ).and_return(broadcast)

    broadcaster.away
    broadcaster.status.should == "Away"
    broadcaster.message.should be_nil
  end
  
  it "can set the status to away with a message" do
    broadcast = stub("broadcast")
    DNSSD.stub!(:register).and_return(broadcast)
    
    broadcaster = Chatjour::Broadcaster.new
    broadcaster.start

    broadcast.should_receive(:stop)
    text_record = DNSSD::TextRecord.new
    text_record['status'] = "Away"
    text_record['message'] = "taking a nap"
    DNSSD.should_receive(:register).with(
      Etc.getlogin, 
      "_chat._tcp", 
      'local', 
      Chatjour::Broadcaster::PORT, 
      text_record.encode
    ).and_return(broadcast)

    broadcaster.away("taking a nap")
    broadcaster.status.should == "Away"
    broadcaster.message.should == "taking a nap"
  end
  
  it "can set the status to available with no message" do
    broadcast = stub("broadcast")
    DNSSD.stub!(:register).and_return(broadcast)

    broadcaster = Chatjour::Broadcaster.new
    broadcaster.start
    
    broadcast.should_receive(:stop)
    text_record = DNSSD::TextRecord.new
    text_record['status'] = "Available"
    text_record['message'] = nil
    DNSSD.should_receive(:register).with(
      Etc.getlogin, 
      "_chat._tcp", 
      'local', 
      Chatjour::Broadcaster::PORT, 
      text_record.encode
    ).and_return(broadcast)
    
    broadcaster.available
    broadcaster.status.should == "Available"
    broadcaster.message.should be_nil
  end
  
  it "can set the status to available with a message" do
    broadcast = stub("broadcast")
    DNSSD.stub!(:register).and_return(broadcast)

    broadcaster = Chatjour::Broadcaster.new
    broadcaster.start

    broadcast.should_receive(:stop)
    text_record = DNSSD::TextRecord.new
    text_record['status'] = "Available"
    text_record['message'] = "hanging out"
    DNSSD.should_receive(:register).with(
      Etc.getlogin, 
      "_chat._tcp", 
      'local', 
      Chatjour::Broadcaster::PORT, 
      text_record.encode
    ).and_return(broadcast)
    
    broadcaster.available("hanging out")
    broadcaster.status.should == "Available"
    broadcaster.message.should == "hanging out"
  end
end