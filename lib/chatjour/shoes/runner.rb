module Chatjour
  module Shoes
    class Runner
      def self.start
        controller = Chatjour::Controller.new(Chatjour::Application.new, Chatjour::Shoes::View.new)
        loop do
          controller.process
          sleep 0.1
        end
      end
    end
  end
end