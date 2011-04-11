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
      html << content_tag(:input,raw("<label>#{way}</label>"),:type => "checkbox",:name => "way[]",:value => index + 1,:checked => checked.include?(index + 1))
    end
    html
  end

  def display_income_report(date,pay_ways)
    table_width = 9 + CommonResource.good_types.count

    table = ''
    table << "<table class='report_table' border=1>"
    table <<("<caption><h1>" + current_catena.name  +  "球馆#{date.to_s(:db)}收入日报表"+ "</h1></caption>")
    # first tr
    table <<("<tr class='head'>")
    table <<("<td colspan=3>日期 #{ select_year(Date.today,:start_year => 2010,:end_year => 2016)} 年 " + 
             "#{select_month(Date.today)}　#{select_day(Date.today)} 日</td>")
    table << "<td>支付方式：　</td>"
    table << "<td colspan=#{table_width - 5}>#{pay_way_checkboxes([1,2,4])}</td>"
    table << "<td><p class='money'>合计：　10.10<p></td>"
    table << "</tr>"

    # second tr
    table << "<tr><td colspan=#{table_width}></td></tr>"

    # title
    table << "<tr class='report_title'>"
    table << "<td>编号</td><td>会员姓名</td><td>卡号</td><td>场地费</td><td>教练费</td><td>培训费</td>"
    CommonResource.good_types.each do |gt|
      table << "<td>#{gt.detail_name}</td>"
    end
    table << "<td>新办卡</td><td>续卡</td><td>合计</td>"
    table << "</tr>"


    # data tr
    Balance.balances_on_date_and_ways(date,pay_ways).each_with_index do |b,index|
      table << "<tr class='report_item'>"
      table <<"<td>#{index+1}</td>"
      table << "<td>#{b.member.name}</td>"
      table << "<td>#{b.order.member_card.card_serial_num}</td>"
      table << "<td>#{b.book_record_realy_amount}</td>"
      table << "<td>#{b.coach_amount}</td>"
      table << "<td>-</td>"
      CommonResource.good_types.each do |gt|
      table << "<td>#{b.good_amount_by_type(gt)}</td>"
      end
      table << "<td>#{}</td>"
      table << "<td>#{}</td>"
      table << "<td>#{}</td>"
      table << "</tr>"
    end

    table << "</table>"
    table

  end

end


