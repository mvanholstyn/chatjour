module Chatjour
  module Ncurses
    class View
      def initialize(options = {})
        @lines, @columns, @line, @buffer = [], [], 0, ""
        
        @window = ::Ncurses.initscr
        @window.scrollok(true)
        @window.getmaxyx(@lines, @columns)
        @lines, @columns = @lines.first, @columns.first
        ::Ncurses.cbreak
        ::Ncurses.nodelay(@window, true)
        prompt
      end
      
      def prompt
        ::Ncurses.mvprintw(@lines - 2, 0, " " * @columns)
        ::Ncurses.mvaddstr(@lines - 2, 0, "> ")
        ::Ncurses.refresh
      end
      
      def write(output)
        output.each_line do |line|
          if @line == @lines - 2
            @line -= 1
            @window.wscrl(1)
          end
          ::Ncurses.mvprintw(@line , 0, line)
          @line += 1
        end
        prompt
      end
      
      def receive
        # special characters don't work, but they echo uglyness
        case ch = @window.getch
          when -1
            # ignore
          when 10 # Enter
            prompt
            input = @buffer
            @buffer = ""
            input
          else
            @buffer << ch.chr
            nil
        end
      end
      
      def display_users(users)
        write "Available Users:"
        users.each do |user|
          write "#{[user.name, user.status, user.message].delete_if { |u| u.empty? }.join(' - ')}"
        end
      end
      
      def display_messages(messages)
        messages.each do |message|
          write "#{message.user.name}: #{message.body}"
        end
      end

      def display_help
        write <<-EOHELP
Available Commands:
  /help
  /users
  /available [message]
  /away [message]
  /invisible
  /visible
  /username message
  message
EOHELP
      end
    end
  end
end