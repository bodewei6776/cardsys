module ReportsHelper

  def display_income_report(date,pay_ways)
    table_width = 9 + CommonResource.good_types.count

    table = ''
    table << "<table>"
    table <<("<caption>" + current_catena.name  +  "球馆#{date.to_s(:db)}收入日报表"+ "</caption>")
    table << "</table>"
    table
    
  end

end
