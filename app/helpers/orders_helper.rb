module OrdersHelper
  def display_period_per_hour(daily_periods, court, date)
    info_htmls = []
    time_spans = []
    daily_periods.each do |period|
      all_spans_per_period = (period.start_time...period.end_time).to_a.map{|i|[i, i+1]}
      if court.is_useable_in_time_span?(period)
        time_spans += all_spans_per_period
      else
        all_spans_per_period.each do |start_hour,end_hour|
          li_height = 24*(end_hour - start_hour)
          info_htmls << [start_hour,content_tag(:li, "场地不可用", :style => "height:#{li_height + 6}px;")]
        end
      end
    end
    court_book_records = court.daily_book_records(date)
    real_time_spans,i = [],0
    while i < time_spans.size
      time_span = time_spans[i]
      if (book_record =  court_book_records.find{|record| record.start_hour == time_span.first})
        while i < time_spans.size && time_spans[i].last < book_record.end_hour
          i += 1
        end
        real_time_spans << [time_span.first,time_spans[i].last, book_record]
      else
        real_time_spans << [time_span.first,time_span.last,nil]
      end
      i += 1
    end
    for real_time_span in real_time_spans
      new_order_params= {:alloc_date => date.to_s(:db), :resource_id => court.id, :start_hour => real_time_span[0], :end_hour => real_time_span[1]}
      book_url = new_order_path(:court_book_record => new_order_params)
      hours = real_time_span[1]-real_time_span[0]
      li_height = 30*(hours) + (hours - 1)
      unless (book_record = real_time_span.last).nil?
        display_content =if book_record.order.is_member?
                           "#{book_record.order.member.name}:#{book_record.order.members_card.card_serial_num}" 
                         else
                           "#{book_record.order.non_member.name}:无卡预定" 
                         end
        display_content = "(授)" + display_content if (book_record.order.members_card_id.present? and \
                                                       book_record.order.is_member? and \
                                                       book_record.order.member.is_granter_of_card(book_record.order.members_card_id))
        display_content = "(固)" +  display_content if book_record.order.advanced_order
        display_content << "(教练:#{book_record.order.coaches.map(&:name).join(',')})" if book_record.order.coaches

        if book_record.order.balanced?
          display_content << "(结算人: #{book_record.order.balance.who_balance.try(:login) || ""})"
        end

        url = edit_order_path(book_record.order)
        li_class = []
        if book_record.order.booked?
          li_class << "book-reocrd-draggable"
          li_class << "book-reocrd-droppable"
        end
        title = "#{display_content}(#{book_record.order.status_desc})"
        info_htmls << [real_time_span[0],content_tag(:li,
                                                     content_tag("a",
                                                                 content_tag(:p, display_content,:style =>  "display:inline-block; height:30px; line-height:15px;"),:href => url,
                                                                 :class => "#{book_record.order.status_color} popup-new-window ",:title => title,
                                                                 :style => "height:#{li_height}px;display:block;vertical-align:middle;display:table-cell;width: 161px;"),:style => "height:#{li_height}px;line-height:#{li_height}px;",
        :class => li_class.join(' '), :id => "book-record-#{book_record.id}")]
      else
        if date < Date.today || (date == Date.today && real_time_span[0] < DateTime.now.hour)
          unless current_user.can_book_when_time_due?
            info_htmls << [real_time_span[0],content_tag(:li,
                                                         tag("input",{:type => 'button', :disabled => 'disabled',:value => '过 期', :class => "color02",:style => "height:#{li_height}px;"}))]

          else
            info_htmls << [real_time_span[0],content_tag(:li,
                                                         content_tag("button","预定",{:type => 'button',:href=> book_url,:value => '预定', 
                                                                     :class => "submit1 hand popup-new-window", :style => "margin-top: 5px;"}) )]
          end
        else
          info_htmls << [real_time_span[0],content_tag(:li,content_tag("button",'预定',{:type => 'button', :href => book_url,
                                                                       :value => '预定',:class => "submit1 hand popup-new-window"  ,:style => "margin-top: 5px;"}))]
        end
      end
    end
    info_htmls.sort{|fst,scd| fst.first <=> scd.first}.map{|info_html| info_html.last}.join(' ').html_safe
  end


  def order_action_link(text, url, confirm_message = "")
    confirm_message = "确认要" + text + "?" if confirm_message.blank?
     link_to(text, url, :confirm_message => confirm_message, :class => "button_link")
  end

  def display_enable_buttons(order)
    htmls = []
    htmls << order_action_link("申请代卖", change_state_order_path(order, :be_action => "want_sell")) if order.can_want_sell?
    htmls << order_action_link("代卖", change_state_order_path(order, :be_action => "sell")) if order.can_sell?
    htmls << order_action_link("取消代卖", change_state_order_path(order, :be_action => "cancel_want_sell")) if order.can_cancel_want_sell?
    htmls << order_action_link("取消预订", change_state_order_path(order, :be_action => "cancel")) if order.can_cancel?
    htmls << order_action_link("连续取消", change_state_order_path(order, :be_action => "cancel_all")) if order.can_cancel_all?
    htmls << order_action_link("连续变更", order_path(order, :be_action => "update_all")) if order.can_update_all?
    htmls << order_action_link("预订已过期，请结算", order_blances_path(order)) if order.book_time_due?
    htmls << order_action_link("代卖已过期，请结算", order_blances_path(order)) if order.to_be_sold_time_due?
    htmls << order_action_link("开场", change_state_order_path(order, :be_action => "active")) if order.can_active?
    htmls << order_action_link("结算", change_state_order_path(order, :be_action => "balanced")) if order.can_blance?
    htmls << order_action_link("添加消费", order_goods_path(order)) if order.can_order_goods?
    htmls << order_action_link("打印消费记录", print_order_balances_path(order)) if order.can_print_order_balance?

    htmls.join(' ').html_safe
  end

  def generate_courts_options(selected_value)
    courts = Court.all
    options = [["所有场地",'-1']] + courts.map{|court| [court.name,"#{court.id}"]}
    options_for_select(options,selected_value.blank? ? nil : selected_value.to_s)
  end

  def generate_book_record_status_options(selected_value)
    options = Court.all.map{|court| [court.name,court.id.to_s] }
    selected_value = selected_value.to_s unless selected_value.blank?
    options_for_select(options,selected_value)
  end

  def generate_coaches_options(coaches,selected_value=nil)
    options = [['请选择教练','0']]
    coaches.each {|coach| options <<  ["#{coach.name} #{coach.fee}/小时",coach.id.to_s]}
    selected_value.blank? and selected_value = '0'
    options_for_select(options,selected_value.to_s)
  end

  def generate_week_options(selected_value)
    week_names  = %w{周一 周二 周三 周四 周五 周六 周日}
    options     = (1..7).to_a.map { |week| [week_names[week-1],week]  }
    options_for_select(options,selected_value)
  end

end
