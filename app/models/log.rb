class Log < ActiveRecord::Base

  def self.log(user,desc,log_type)
    new(:user_name => user.login,:user_id => user.id,:desc => desc,:log_type => log_type).save
  end
end
