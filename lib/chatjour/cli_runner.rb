module Chatjour
  class CliRunner
  
    def initialize(args)
      controller = Controller.new(Application.new, CliView.new)
      
      loop do
        controller.process
        sleep 0.1
      end
    end
  end
  
  class CliView
    def receive
      STDIN.read_nonblock(1024)
    rescue Errno::EAGAIN
    end
  end
end