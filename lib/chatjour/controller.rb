module Chatjour
  class Controller
    def initialize(app, view)
      @app, @view = app, view
    end
    
    def process
      if input = @view.receive
        @app.process(input)
      end
      
      if output = @app.receive
        @view.display(@output)
      end
    end
  end
end