# -*- encoding : utf-8 -*-
module RentsHelper

  def rents_in_table(lockers,date = Date.today)
    locker_groups = lockers.group_by(&:locker_type)
    table_width = 11
    content = "<table id='rent_table' cellspacing='0'>"
    content += "<tr><th>分类</th><th colspan='10'>储物柜</th></tr>"
    locker_groups.each do |locker_group,lockers|
      lockers_count = lockers.count
      group_height = (lockers_count.to_f / (table_width - 1)).ceil
      content += "<tr>"
      content += "<td rowspan='#{group_height}' class='rent_group_name'>#{locker_type_from_id(locker_group)}</td>"
      ([table_width - 1,lockers_count].min).times do |i|
        content += "<td>#{locker_widget(lockers[i] ,date) unless lockers[i].blank?}</td>"
      end
      remaining_td_count = lockers_count - (table_width - 1)
      if(remaining_td_count > 0)
        content += "</tr>"
        count = table_width - 1
        ((table_width-1)..lockers_count-1).each_slice(table_width-1) do |slice|
        content += "<tr>"
          slice.each do |i|
            content += "<td>#{locker_widget(lockers[count] ,date) unless lockers[count].blank?}</td>"
            count += 1
          end
        content += "</tr>"
        end
      end
      content += "</tr>"
    end
    content += "</table>"
    content.html_safe
  end

  def locker_widget(locker,date = Date.today)
    div = "<div class=' #{locker.style(date)} locker_div popup-new-window hand'" 
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
