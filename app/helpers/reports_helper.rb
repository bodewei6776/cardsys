# -*- encoding : utf-8 -*-
module ReportsHelper

  def pay_way_checkboxes(checked = [])
    map = [["记账", "card"],["计次", "counter"],["现金" , "cash"],["POS机" , "pos"],["支票" , "check"],["银行转账" , "bank"], ["挂账" , "guazhang"]]
    html = ""
    map.each do |way|
      html << content_tag(:input,raw("#{way[0]}"),:type => "checkbox",:name => "pay_ways[]", :value => way[1], :checked => checked.include?(way[1].to_s), :onclick=> "recalculate();" , :class=>"pay_ways")
    end

    html
  end


  def book_record_amount_desc(b, pay_ways)
    return 0 if pay_ways.blank?
    if pay_ways.include?("counter") && b.balance_way == "counter"
      "#{}次"
    else
      "#{b.book_record_amount(pay_ways)}元"
    end
  end

  def display_income_report(date, pay_ways)
    table_width = 7 + Category.roots.count

    table = ''
    table << "<table class='report_table' border=1>"
    table <<("<caption><h1>#{Setting.site_name}#{date.to_s(:db)}收入日报表"+ "</h1></caption>")
    # first tr
    table <<("<tr class='head'>")
    table <<("<td colspan=3>日期 #{ select_year(date, {:start_year => 2010,:end_year => 2016},:onchange => "recalculate();")} 年 " + 
             "#{select_month(date,:use_month_numbers => true,:onchange => "recalculate();")}月　#{select_day(date,{},:onchange => "recalculate();")} 日</td>")
    table << "<td>支付方式：　</td>"
    table << "<td colspan=#{table_width - 5} style='width:450px;'>#{pay_way_checkboxes(pay_ways)}</td>"
    table << "<td>合计：　#{Balance.total_balance_on_date_any_ways(date, pay_ways)}  </td>"
    table << "</tr>"

    # second tr
    table << "<tr class='sep'><td colspan=#{table_width}></td></tr>"

    # title
    table << "<tr class='report_title'>"
    table << "<td>编号</td> <td>会员姓名</td><td>时间和场地号</td> <td>卡号</td><td>场地费</td><td>教练费</td>"
    Category.roots.each do |gt|
      table << "<td>#{link_to(gt.name,{:controller => "reports",:action => "good_type_day",:id => gt.id,:date => date},:class => "link_to_good_type")}</td>"
    end
    table << "<td>合计</td>"
    table << "</tr>"

    # data tr
    Balance.balances_on_date_and_ways(date, pay_ways).each_with_index do |b,index|
      table << "<tr class='report_item'>"
      table <<"<td>#{index+1} </td>"
      table << "<td>#{link_to(b.order.member_name,order_balance_path(b.order,b),:target => "_blank")}</td>"
      table << "<td>#{b.money_spent_on}</td>"
      table << "<td>#{b.order.members_card.card_serial_num rescue ""}</td>"
      table << "<td class='mon'>#{ book_record_amount_desc(b, pay_ways)}</td>"
      table << "<td class='mon'>#{b.coach_amount(pay_ways)}</td>"
      Category.roots.each do |gt|
        table << "<td class='mon'>#{b.good_amount_by_type(gt, pay_ways)}</td>"
      end
      table << "<td class='mon'>#{b.balance_amount_by_ways(pay_ways)}</td>"
      table << "</tr>"
    end

    # last tr

    table << "<tr class='total head'>"
    table << "<td colspan=4>合计: #{Balance.total_balance_on_date_any_ways(date, pay_ways)}  </td>"
    table << "<td class='mon'> #{Balance.total_book_records_balance_on_date_any_ways(date, pay_ways)}</td>"
    table << "<td class='mon'> #{Balance.total_coach_balance_on_date_any_ways(date, pay_ways)}</td>"
  Category.roots.each do |gt|
    table << "<td class='mon'> #{Balance.total_goods_balance_on_date_any_ways(date, pay_ways, gt)}</td>"
      end
    table << "<td>合计: #{Balance.total_balance_on_date_any_ways(date,pay_ways)} </td>"
    table << "</tr>"
    table << "</table>"
    table

  end


  def choose_month(date)
    select_tag("",options_for_select((1..Date.today.month).to_a,date.month),:onchange=> "recalculate();",:id => "date_month")
  end


  def display_month_income_report(date, selected_way, pay_ways)
    table_width = 5 + Category.roots.count

    table = ''
    table << "<table class='report_table' border=1>"
    table <<("<caption><h1>" + Setting.site_name +  "#{date.strftime("%y-%m")}收入月报表"+ "</h1></caption>")
    # first tr%
    table <<("<tr class='head'>")
    table <<("<td colspan=3>日期 #{ select_year(date,{:start_year => 2008,:end_year => Date.today.year},:onchange => "recalculate();")} 年 " + 
             "#{choose_month(date)}月</td>")
    table << "<td>支付方式：　</td>"
    table << "<td colspan=#{table_width - 5}>#{pay_way_checkboxes(pay_ways)}</td>"
    table << "<td><p class='money'>合计：　#{Balance.total_balance_on_month_any_ways(date, pay_ways)}<p></td>"
    table << "</tr>"

    # second tr
    table << "<tr class='sep'><td colspan=#{table_width}></td></tr>"

    # title
    table << "<tr class='report_title'>"
    table << "<td>编号</td><td>日期</td><td>场地费</td><td>教练费</td>"
    Category.roots.each do |gt|
      table << "<td>#{gt.name}</td>"
    end
    table << "<td>合计</td>"
    table << "</tr>"

    # data tr
    (1..(days_in_month(date.year,date.month))).each_with_index do |day,index|
      current_date = date + index
      table << "<tr class='report_item'>"
      table <<"<td>#{index+1}</td>"
      table << "<td> #{ link_to current_date, reports_income_path(:date => current_date), :target => "_blank"}</td>"
      table << "<td class='mon'>#{Balance.total_book_records_balance_on_date_any_ways(current_date, pay_ways)}</td>"
      table << "<td class='mon'>#{Balance.total_coach_balance_on_date_any_ways(current_date, pay_ways)}</td>"
      Category.roots.each do |gt|
      table << "<td class='mon'>#{Balance.total_goods_balance_on_date_any_ways(current_date, pay_ways,gt)}</td>"
      end
      table << "<td class='mon'>#{Balance.total_balance_on_date_any_ways(current_date, pay_ways)} </td>"
      table << "</tr>"
    end

    # last tr

    table << "<tr class='total head'>"
    table << "<td colspan=2>合计: #{Balance.total_balance_on_month_any_ways(date,pay_ways)}</td>"
    table << "<td class='mon'> #{Balance.total_book_records_balance_on_month_any_ways(date,pay_ways)} </td>"
    table << "<td class='mon'> #{Balance.total_coach_balance_on_month_any_ways(date,pay_ways)}</td>"
  Category.roots.each do |gt|
    table << "<td class='mon'> #{Balance.total_goods_balance_on_month_any_ways(date, pay_ways, gt)}</td>"
      end
    table << "<td>合计: #{Balance.total_balance_on_month_any_ways(date,pay_ways)}</td>"
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
    table << "<td>科目：　</td><td>#{good_type.name}</td><td>时间：</td><td colspan=2>#{date.to_s(:db)}</td>"
    table << "<tr class='sep'><td colspan=#{table_width}></td></tr>"

    table << "<tr class='report_title'>"
    table << "<td>编号</td><td>名称</td><td>数量</td><td>单价</td><td>合计</td>"
    table << "</tr>"

    i = 1
    Balance.good_stat_per_date_by_type_with_order_item(date, good_type).each do |good, quantity, price_after_discount|
    table << "<tr>"
    table << "<td>#{i}</td>"
    table << "<td>#{good.name}</td>"
    table << "<td class='mon'>#{quantity}</td>"
    table << "<td class='mon'>#{good.price}</td>"
    table << "<td class='mon'>#{price_after_discount}</td>"
    table << "</tr>"
    i = i+1
    end

    table << "<tr>"
    table << "<td>合计</td>"
    table << "<td></td>"
    table << "<td></td>"
    table << "<td></td>"
    table << "<td class='mon'>#{Balance.good_total_per_date_by_type(date, good_type)}</td>"
    table << "</tr>"


    table << "</table>"

  end

end


