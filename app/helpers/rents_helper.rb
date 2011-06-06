module RentsHelper

  def rents_in_table(lockers,date = Date.today)
    locker_groups = lockers.group_by(&:locker_type)
    max_td_num = locker_groups.values.sort{|v| v.size}.last.size rescue 0
    table_width =(max_td_num + 1)*100
    content = "<table id='rent_table' cellspacing='0' style='width: #{table_width}px;'>"
    content += "<tr><th>分类</th><th colspan='#{max_td_num}'>储物柜</th></tr>"
    locker_groups.each do |locker_group,lockers|
      content += "<tr>"
      content += "<td>#{locker_type_from_id(locker_group)}</td>"
      max_td_num.times do |i|
        content += "<td>#{locker_widget(lockers[i] ,date) unless lockers[i].blank?}</td>"
      end
      content += "</tr>"
    end
    content += "</table>"
    content.html_safe
  end

  def locker_widget(locker,date = Date.today)
    div = "<div style='background-color:#{locker.color(date)};' class='locker_div popup-new-window hand'" 
    div += " href='#{locker.rented? ? edit_locker_rent_path(locker,locker.current_rent) : new_locker_rent_path(locker,:date => date)}'>"
    div += locker.num 
    div += "</div>"
  end

  def locker_color(locker,date = Date.today)
  end

  def locker_type_from_id id
    CommonResourceDetail.find(id).detail_name rescue "未找到"
  end
end
