# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)
user = User.create(:login => "admin",:password => "admin01",:password_confirmation => "admin01",:user_name => "超级管理员",:catena_id => 1)
if (catena = Catena.find_by_id(1)).blank?
  catena = Catena.new(:id => 1, :name => '连锁1')
  catena.id = 1
  catena.save
end
card_type = CommonResource.create(:name => "card_type", :description => "卡类型", :detail_str => "储值卡 记次卡")
period_type = CommonResource.create(:name => "period_type", :description => "时段类型", :detail_str => "夏令时 冬令时 节假日")
coach_type= CommonResource.create(:name => "coach_type", :description => "教练类型", :detail_str => "全职教练 客人自带")
cert_type = CommonResource.create(:name => "cert_type", :description => "证件类型", :detail_str => "身份证 军人证")
good_type = CommonResource.create(:name => "good_type", :description => "商品类型", :detail_str => "食品 球具")
good_source = CommonResource.create(:name => "good_source", :description => "商品来源", :detail_str => "代卖")
times_summer = CommonResource.create(:name => "times_summer", :description => "夏令时", :detail_str => "3 10")
times_winter = CommonResource.create(:name => "times_winter", :description => "冬令时", :detail_str => "12 1 2")

#Type_Member_Name,Type_blance_Name,Type_Connter_Name,Type_Zige_Name = '会员卡', '储值卡', '记次卡','资格卡'#会员卡 储值卡 记次卡
CommonResourceDetail.create(:common_resource_id => card_type.id, :detail_name => "储值卡", :catena_id => catena.id)
CommonResourceDetail.create(:common_resource_id => card_type.id, :detail_name => "会员卡", :catena_id => catena.id)
CommonResourceDetail.create(:common_resource_id => card_type.id, :detail_name => "记次卡", :catena_id => catena.id)
CommonResourceDetail.create(:common_resource_id => card_type.id, :detail_name => "资格卡", :catena_id => catena.id)

CommonResourceDetail.create(:common_resource_id => period_type.id, :detail_name => "夏令时", :catena_id => catena.id)
CommonResourceDetail.create(:common_resource_id => period_type.id, :detail_name => "冬令时", :catena_id => catena.id)
CommonResourceDetail.create(:common_resource_id => period_type.id, :detail_name => "节假日", :catena_id => catena.id)

CommonResourceDetail.create(:common_resource_id => coach_type.id, :detail_name => "全职教练", :catena_id => catena.id)
CommonResourceDetail.create(:common_resource_id => coach_type.id, :detail_name => "客人自带", :catena_id => catena.id)

CommonResourceDetail.create(:common_resource_id => cert_type.id, :detail_name => "身份证", :catena_id => catena.id)
CommonResourceDetail.create(:common_resource_id => cert_type.id, :detail_name => "军人证", :catena_id => catena.id)

CommonResourceDetail.create(:common_resource_id => good_type.id, :detail_name => "食品", :catena_id => catena.id)
CommonResourceDetail.create(:common_resource_id => good_type.id, :detail_name => "球具", :catena_id => catena.id)

CommonResourceDetail.create(:common_resource_id => good_source.id, :detail_name => "带卖", :catena_id => catena.id)

CommonResourceDetail.create(:common_resource_id => times_summer.id, :detail_name => "3", :catena_id => catena.id)
CommonResourceDetail.create(:common_resource_id => times_summer.id, :detail_name => "4", :catena_id => catena.id)
CommonResourceDetail.create(:common_resource_id => times_summer.id, :detail_name => "5", :catena_id => catena.id)
CommonResourceDetail.create(:common_resource_id => times_summer.id, :detail_name => "6", :catena_id => catena.id)
CommonResourceDetail.create(:common_resource_id => times_summer.id, :detail_name => "7", :catena_id => catena.id)
CommonResourceDetail.create(:common_resource_id => times_summer.id, :detail_name => "8", :catena_id => catena.id)
CommonResourceDetail.create(:common_resource_id => times_summer.id, :detail_name => "9", :catena_id => catena.id)
CommonResourceDetail.create(:common_resource_id => times_summer.id, :detail_name => "10", :catena_id => catena.id)
CommonResourceDetail.create(:common_resource_id => times_summer.id, :detail_name => "11", :catena_id => catena.id)

CommonResourceDetail.create(:common_resource_id => times_winter.id, :detail_name => "12", :catena_id => catena.id)
CommonResourceDetail.create(:common_resource_id => times_winter.id, :detail_name => "1", :catena_id => catena.id)
CommonResourceDetail.create(:common_resource_id => times_winter.id, :detail_name => "2", :catena_id => catena.id)