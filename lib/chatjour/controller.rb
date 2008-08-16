module Chatjour
  class Controller
    def initialize(app, view)
      @app, @view = app, view
      @app.start
    end
    
    def process
      process_view
      process_app
    end
    
    def process_view
      if input = @view.receive
        case input
          when "/users";         @view.display_users(@app.users)
          when "/help";          @view.display_help
          when /^\/(\w+) (.*)$/; @app.tell($1, $2)
          else;                  @app.say(input)
        end
      end
    end

    def process_app
      @view.display_messages(@app.receive)
    end
  end
end