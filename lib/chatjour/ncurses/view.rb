module Chatjour
  module Ncurses
    class View
      def initialize(options = {})
        @lines, @columns, @line, @buffer = [], [], 0, ""
        
        @window = ::Ncurses.initscr
        @window.getmaxyx(@lines, @columns)
        @lines, @columns = @lines.first, @columns.first
        ::Ncurses.cbreak
        ::Ncurses.nodelay(@window, true)
        prompt
      end
      
      def prompt
        ::Ncurses.mvprintw(@lines - 1, 0, " " * @columns)
        ::Ncurses.mvaddstr(@lines - 1, 0, "> ")
        ::Ncurses.refresh
      end
      
      def write(output)
        output.each do |line|
          ::Ncurses.mvprintw(@line , 0, line)
          @line += 1
        end
        prompt
      end
      
      def receive
        ch = @window.getch
        if ch == -1
          # ignore
        elsif ch.chr == "\n"
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
          write <<-EOUSER
  #{[user.name, user.status, user.message].delete_if { |u| u.empty? }.join(' - ')}
EOUSER
        end
      end
      
      def display_messages(messages)
        messages.each do |message|
          write <<-EOUSER
Message:
  #{message.body}
EOUSER
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