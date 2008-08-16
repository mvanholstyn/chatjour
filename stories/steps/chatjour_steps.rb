steps_for :chatjour do
  Given "$user starts up Chatjour" do |user|
    @portno ||= 25800
    @users ||= {}
    @users[user] = {
      :name => user,
      :input => StringIO.new, 
      :output => StringIO.new,
      :public_port => @portno+=1,
      :private_port => @portno+=1
    }
    @users[user][:app] = Chatjour::Application.new(@users[user])
    @users[user][:app].run
  end
  
  
  When "$user asks for a list of users" do |user|
    @users[user][:input].puts "users"
  end
  
  
  Then "$current_user should see that $user1 and $user2 are registered to talk over Chatjour" do |current_user, user1, user2|
    @users[current_user][:output].string.should =~ /#{user1}/m
    @users[current_user][:output].string.should =~ /#{user2}/m
    @users[current_user][:output].string.replace("")
  end

end