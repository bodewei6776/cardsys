require 'highline/import'

task :summer_or_winter => :environment do
  CommonResource.delete_all(:name => ["times_summer","times_winter"])
  while  true do
    result = ask("是否区分冬令时，夏令时?[yes|no]")

    case result
    when /^[Y|y]es$/
      times_summer = CommonResource.create(:name => "times_summer", :description => "夏令时", :detail_str => "5 10")
      times_winter = CommonResource.create(:name => "times_winter", :description => "冬令时", :detail_str => "11 12 1 2 3 4")
      5.upto(10) do |i|
        CommonResourceDetail.create(:common_resource_id => times_summer.id, :detail_name => i.to_s)
      end
      [11,12,1,2,3,4].each do |i|
        CommonResourceDetail.create(:common_resource_id => times_winter.id, :detail_name => i.to_s)
      end
      break;
    when /^[N|n]o$/

      times_summer = CommonResource.create(:name => "times_summer", :description => "夏令时", :detail_str => "1 12")
      1.upto(12) do |i|
        CommonResourceDetail.create(:common_resource_id => times_summer.id, :detail_name => i.to_s)
      end

      break;
    else
      puts 'retry'
    end

  end
end
