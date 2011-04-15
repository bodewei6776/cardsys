module ReportsHelper

  def pay_way_checkboxes(checked)
    #  Balance_Way_Use_Card  = 1
    #  Balance_Way_Use_Cash  = 2
    #  Balance_Way_Use_Post  = 3
    #  Balance_Way_Use_Bank  = 4
    #  Balance_Way_Use_Check = 5
    #  Balance_Way_Use_Guazhang = 6
    #  Balance_Way_Use_Counter  = 7
    html = ""
    ["用卡","现金","POS机","银行转账","支票","挂账","记账"].each_with_index do |way,index|
      html << content_tag(:input,raw("<label>#{way}</label>"),:type => "checkbox",:name => "way[]",:value => index + 1,:checked => checked.include?((index + 1).to_s),:onclick=> "recalculate();" ,:class=>"pay_ways")
    end
    html
  end

  def display_income_report(date,pay_ways)
    table_width = 6 + CommonResource.good_types.count

    table = ''
    table << "<table class='report_table' border=1>"
    table <<("<caption><h1>" + current_catena.name  +  "球馆#{date.to_s(:db)}收入日报表"+ "</h1></caption>")
    # first tr
    table <<("<tr class='head'>")
    table <<("<td colspan=3>日期 #{ select_year(date,{:start_year => 2010,:end_year => 2016},:onchange => "recalculate();")} 年 " + 
             "#{select_month(date,{},:onchange => "recalculate();")}　#{select_day(date,{},:onchange => "recalculate();")} 日</td>")
    table << "<td>支付方式：　</td>"
    table << "<td colspan=#{table_width - 5}>#{pay_way_checkboxes(pay_ways)}</td>"
    table << "<td><p class='money'>合计：　#{Balance.total_balance_on_date_any_ways(date,pay_ways)}<p></td>"
    table << "</tr>"

    # second tr
    table << "<tr class='sep'><td colspan=#{table_width}></td></tr>"

    # title
    table << "<tr class='report_title'>"
    table << "<td>编号</td><td>会员姓名</td><td>卡号</td><td>场地费</td><td>教练费</td>"
    CommonResource.good_types.each do |gt|
      table << "<td>#{link_to(gt.detail_name,{:controller => "reports",:action => "good_type_day",:id => gt.id,:date => date},:class => "link_to_good_type")}</td>"
    end
    table << "<td>合计</td>"
    table << "</tr>"

    # data tr
    Balance.balances_on_date_and_ways(date,pay_ways).each_with_index do |b,index|
      table << "<tr class='report_item'>"
      table <<"<td>#{index+1}</td>"
      table << "<td>#{b.member.name}（#{b.book_record_span}）</td>"
      table << "<td>#{b.order.member_card.card_serial_num}</td>"
      table << "<td class='mon'>#{b.book_record_realy_amount}</td>"
      table << "<td class='mon'>#{b.coach_amount}</td>"
      CommonResource.good_types.each do |gt|
      table << "<td class='mon'>#{b.good_amount_by_type(gt)}</td>"
      end
      table << "<td class='mon'>#{b.book_record_realy_amount + b.goods_realy_amount}</td>"
      table << "</tr>"
    end

    # last tr

    table << "<tr class='total head'>"
    table << "<td colspan=3>合计: #{Balance.total_balance_on_date_any_ways(date,pay_ways)}</td>"
    table << "<td class='mon'> #{Balance.total_book_records_balance_on_date_any_ways(date,pay_ways)}</td>"
    table << "<td class='mon'> #{Balance.total_coach_balance_on_date_any_ways(date,pay_ways)}</td>"
  CommonResource.good_types.each do |gt|
    table << "<td class='mon'> #{Balance.total_goods_balance_on_date_any_ways(date,pay_ways,gt)}</td>"
      end
    table << "<td>合计: #{Balance.total_balance_on_date_any_ways(date,pay_ways)}</td>"
    table << "</tr>"
    table << "</table>"
    table

  end


  def display_month_income_report(date,pay_ways)
    table_width = 5 + CommonResource.good_types.count

    table = ''
    table << "<table class='report_table' border=1>"
    table <<("<caption><h1>" + current_catena.name  +  "球馆#{date.strftime("%y-%m")}收入月报表"+ "</h1></caption>")
    # first tr%
    table <<("<tr class='head'>")
    table <<("<td colspan=3>日期 #{ select_year(date,{:start_year => 2010,:end_year => 2016},:onchange => "recalculate();")} 年 " + 
             "#{select_month(date,{},:onchange => "recalculate();")}</td>")
    table << "<td>支付方式：　</td>"
    table << "<td colspan=#{table_width - 5}>#{pay_way_checkboxes(pay_ways)}</td>"
    table << "<td><p class='money'>合计：　#{Balance.total_balance_on_date_any_ways(date,pay_ways)}<p></td>"
    table << "</tr>"

    # second tr
    table << "<tr class='sep'><td colspan=#{table_width}></td></tr>"

    # title
    table << "<tr class='report_title'>"
    table << "<td>编号</td><td>日期</td><td>场地费</td><td>教练费</td>"
    CommonResource.good_types.each do |gt|
      table << "<td>#{gt.detail_name}</td>"
    end
    table << "<td>合计</td>"
    table << "</tr>"

    # data tr
    (1..(days_in_month(date.year,date.month))).each_with_index do |day,index|
      current_date = date + index
      table << "<tr class='report_item'>"
      table <<"<td>#{index+1}</td>"
      table << "<td> #{ current_date}</td>"
      table << "<td class='mon'>#{Balance.total_book_records_balance_on_date_any_ways(current_date,pay_ways)}</td>"
      table << "<td class='mon'>#{Balance.total_coach_balance_on_date_any_ways(current_date,pay_ways)}</td>"
      CommonResource.good_types.each do |gt|
      table << "<td class='mon'>#{Balance.total_goods_balance_on_date_any_ways(current_date,pay_ways,gt)}</td>"
      end
      table << "<td class='mon'>#{Balance.total_balance_on_date_any_ways(current_date,pay_ways)}</td>"
      table << "</tr>"
    end

    # last tr

    table << "<tr class='total head'>"
    table << "<td colspan=2>合计: #{Balance.total_balance_on_date_any_ways(date,pay_ways)}</td>"
    table << "<td class='mon'> #{Balance.total_book_records_balance_on_date_any_ways(date,pay_ways)}</td>"
    table << "<td class='mon'> #{Balance.total_coach_balance_on_date_any_ways(date,pay_ways)}</td>"
  CommonResource.good_types.each do |gt|
    table << "<td class='mon'> #{Balance.total_goods_balance_on_date_any_ways(date,pay_ways,gt)}</td>"
      end
    table << "<td>合计: #{Balance.total_balance_on_date_any_ways(date,pay_ways)}</td>"
    table << "</tr>"
    table << "</table>"
    table

  end



  def display_good_type_day_report(date,good_type)
  table_width = 5
    table = ''
    table << "<table class='report_table' border=1>"
    table <<("<caption><h1>" + "出库单"+ "</h1></caption>")

    table << "<tr class='report_title'>"
    table << "<td>科目：　</td><td>#{good_type.detail_name}</td><td>时间：</td><td colspan=2>#{date.to_s(:db)}</td>"
    table << "<tr class='sep'><td colspan=#{table_width}></td></tr>"

    table << "<tr class='report_title'>"
    table << "<td>编号</td><td>名称</td><td>数量</td><td>单价</td><td>合计</td>"
    table << "</tr>"

    i = 1
    Balance.good_stat_per_date_by_type(date,good_type).each do |good,quantity|
    table << "<tr>"
    table << "<td>#{i}</td>"
    table << "<td>#{good.name}</td>"
    table << "<td class='mon'>#{quantity}</td>"
    table << "<td class='mon'>#{good.price}</td>"
    table << "<td class='mon'>#{quantity * good.price}</td>"
    table << "</tr>"
    i = i+1
    end

    table << "<tr>"
    table << "<td>合计</td>"
    table << "<td></td>"
    table << "<td></td>"
    table << "<td></td>"
    table << "<td class='mon'>#{Balance.good_total_per_date_by_type(date,good_type)}</td>"
    table << "</tr>"


    table << "</table>"

  end

end

