steps_for :chatjour do
  Given "$user starts up Chatjour" do |user|
    @users ||= {}
    stdin, stdout, stderr = Open3.popen3("bin/chatjour #{user}")
    @users[user] = OpenStruct.new(:stdin => stdin, :stdout => stdout, :stderr => stderr)
  end
  
  
  When "$user asks for a list of users" do |user|
    @users[user].stdin.puts "list"
  end
  
  
  Then "$current_user should see that $user1 and $user2 are registered to talk over Chatjour" do |current_user, user1, user2|
  end

end