class UserSession < Authlogic::Session::Base


  def to_key
    now = Time.now
    ["#{now.to_i}","#{now.usec}","#{Process.pid}"]
  end

end
