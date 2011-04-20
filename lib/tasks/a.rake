task :data_d => :environment do

agent_to_buy_time = CommonResource.create(:name => "agent_to_buy_time", :description => "申请代卖提前时间(小时)", :detail_str => "1")
cancle_time = CommonResource.create(:name => "cancle_time", :description => "低于此时间不得取消（小时)", :detail_str => "24")
change_time = CommonResource.create(:name => "change_time", :description => "少余此时间不得变更(小时)", :detail_str => "0")
active_time = CommonResource.create(:name => "active_time", :description => "低于此时间不得开场(分钟)", :detail_str => "30")


end
