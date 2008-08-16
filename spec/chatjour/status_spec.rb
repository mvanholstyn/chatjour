require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Chatjour::Application do
  it "broadcasts via DNSSD" do
    broadcast = stub("broadcast")

    text_record = DNSSD::TextRecord.new
    text_record['status'] = "Available"
    text_record['message'] = nil
    DNSSD.should_receive(:register).with(
      Etc.getlogin, 
      "_chat._tcp", 
      'local', 
      Chatjour::Status::BONJOUR_PORT, 
      text_record.encode
    ).and_return(broadcast)
    
    Chatjour::Status.new.start
  end
  
  it "stops broadcasting via DNSSD" do
    broadcast = stub("broadcast")
    DNSSD.stub!(:register).and_return(broadcast)
    broadcast.should_receive(:stop)
    status = Chatjour::Status.new
    status.start
    status.stop
  end
end