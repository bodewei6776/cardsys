# To change this template, choose Tools | Templates
# and open the template in the editor.
period_price1 = PeriodPrice.create(:name => '晨练时段', :start_time => '7', :end_time => '9', :price => '100', :period_type => CommonResource::PERIOD_TYPE_0, :catena_id => '1')
period_price2 = PeriodPrice.create(:name => '晨练时段', :start_time => '7', :end_time => '9', :price => '100', :period_type => CommonResource::PERIOD_TYPE_1, :catena_id => '1')
period_price3 = PeriodPrice.create(:name => '晨练时段', :start_time => '7', :end_time => '9', :price => '100', :period_type => CommonResource::PERIOD_TYPE_2, :catena_id => '1')

period_price4 = PeriodPrice.create(:name => '休闲时段', :start_time => '9', :end_time => '14', :price => '200', :period_type => CommonResource::PERIOD_TYPE_0, :catena_id => '1')
period_price5 = PeriodPrice.create(:name => '休闲时段', :start_time => '9', :end_time => '16', :price => '200', :period_type => CommonResource::PERIOD_TYPE_1, :catena_id => '1')
period_price6 = PeriodPrice.create(:name => '休闲时段', :start_time => '22', :end_time => '24', :price => '200', :period_type => CommonResource::PERIOD_TYPE_0, :catena_id => '1')
period_price7 = PeriodPrice.create(:name => '休闲时段', :start_time => '22', :end_time => '24', :price => '200', :period_type => CommonResource::PERIOD_TYPE_1, :catena_id => '1')
period_price8 = PeriodPrice.create(:name => '休闲时段', :start_time => '22', :end_time => '24', :price => '200', :period_type => CommonResource::PERIOD_TYPE_2, :catena_id => '1')

period_price9 = PeriodPrice.create(:name => '黄金时段', :start_time => '14', :end_time => '22', :price => '300', :period_type => CommonResource::PERIOD_TYPE_0, :catena_id => '1')
period_price10 = PeriodPrice.create(:name => '黄金时段', :start_time => '16', :end_time => '22', :price => '300', :period_type => CommonResource::PERIOD_TYPE_1, :catena_id => '1')
period_price11 = PeriodPrice.create(:name => '黄金时段', :start_time => '7', :end_time => '22', :price => '300', :period_type => CommonResource::PERIOD_TYPE_2, :catena_id => '1')

period_price = PeriodPrice.new
for i in (1..11)
  case i
  when 1 then period_price = period_price1
  when 2 then period_price = period_price2
  when 3 then period_price = period_price3
  when 4 then period_price = period_price4
  when 5 then period_price = period_price5
  when 6 then period_price = period_price6
  when 7 then period_price = period_price7
  when 8 then period_price = period_price8
  when 9 then period_price = period_price9
  when 10 then period_price = period_price10
  when 11 then period_price = period_price11
  end
  if !period_price.nil?
    #给场地设置默认的时段
    Court.where(:catena_id => 1).each { |court|
    CourtPeriodPrice.create(:period_price_id => period_price1.id,
      :court_price =>  period_price1.price,
      :court_id => court.id,
      :catena_id =>  1)
    }
  end
end