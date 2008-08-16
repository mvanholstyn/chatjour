module Chatjour
  module Ncurses
    class View
      def initialize(options = {})
        @lines, @columns, @buffer = [], [], ""
        
        @window = ::Ncurses.initscr
        @window.getmaxyx(@lines, @columns)
        @lines, @columns = @lines.first, @columns.first

        @chat_line = 1
        @chat = ::Ncurses.newwin(@lines - 3, @columns, 0, 0)
        @chat.scrollok(true)
        @chat.box(0, 0)
        @chat.refresh
        
        # @input = ::Ncurses::Form::FIELD.new(3, @columns, @lines - 3, 0, 0 ,0)
        # @form = ::Ncurses::Form.new_form([@input])
        # @form.post_form
      end
      
      def write(output)
        output.each_line do |line|
          @chat.move(@chat_line, 1)
          @chat.printw(" #{output}\n")
          @chat_line +=1 unless @chat_line == @lines - 4
          @chat.box(0, 0)
          @chat.refresh
        end
      end

      def receive
        # ch = @window.getch
        # return nil if ch == -1
        # case ch
        #   when 10
        #     result = @buffer.dup
        #     ::Ncurses::Form.form_driver(@form, ::Ncurses::Form::REQ_DEL_LINE)
        #     @buffer.replace("")
        #     return result
        #   when 127
        #     ::Ncurses::Form.form_driver(@form, ::Ncurses::Form::REQ_DEL_PREV)
        #   when 260
        #     ::Ncurses::Form.form_driver(@form, ::Ncurses::Form::REQ_LEFT_CHAR)
        #   when 261
        #     ::Ncurses::Form.form_driver(@form, ::Ncurses::Form::REQ_RIGHT_CHAR)
        #   else
        #     @buffer << ch.chr
        #     # ::Ncurses::Form.form_driver(@form, ch)
        # end
        # nil
      end
      
      def display_users(users)
        write "Available Users:"
        users.each do |user|
          write "  #{[user.name, user.status, user.message].delete_if { |u| u.empty? }.join(' - ')}"
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