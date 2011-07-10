class Log < ActiveRecord::Base

  LOG_TYPE = {
    :kaika           => "开卡",
    :chongzhi        => "充值",
    :biangengzongjia => "变更总价",
    :book => "预定",
    :agent => "申请代卖",
    :do_agent => "代卖",
    :balance => "结算",
    :active => "开场",
    :cancle => "取消预定",
    :change_coaches => "变更教练"
  }

  def self.log(controller,desc,log_type,user)
    user = user || controller.send("current_user")
    new(:remote_ip =>controller.request.remote_ip,
        :user_name => user.login,
        :user_id => user.id,
        :desc => desc,
        :log_type => log_type).save
  end
end
