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
          when "/help";                   @view.display_help
          when /^\/available(?: (.*))?$/; @app.broadcaster.available($1)
          when /^\/away(?: (.*))?$/;      @app.broadcaster.away($1)
          when "/invisible";              @app.broadcaster.stop
          when "/visible";                @app.broadcaster.start
          when "/users";                  @view.display_users(@app.buddy_list.users)
          when /^\/(\w+) (.*)$/;          @app.messenger.tell($1, $2)
          else;                           @app.messenger.say(input)
        end
      end
    end

    def process_app
      @view.display_messages(@app.messenger.receive)
    end
  end
end