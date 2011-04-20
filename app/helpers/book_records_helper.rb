module BookRecordsHelper

  def display_period_per_hour(daily_periods,court,date)
    info_htmls = []
    time_spans = []
    daily_periods.each do |period|
      all_spans_per_period = (period.start_time...period.end_time).to_a.map{|i|[i,i+1]}
      if court.is_useable_in_time_span?(period)
        time_spans += all_spans_per_period
      else
        all_spans_per_period.each do |start_hour,end_hour|
          li_height = 24*(end_hour - start_hour)
          info_htmls << [start_hour,content_tag(:li,"场地不可用",:style => "height:#{li_height + 6}px;")]
        end
      end
    end
    court_book_records = court.daily_book_records(date).all
    realy_time_spans,i = [],0
    while i < time_spans.size
      time_span = time_spans[i]
      if (book_record =  court_book_records.find{|record|record.start_hour == time_span.first})
        while i < time_spans.size && time_spans[i].last < book_record.end_hour
          i += 1
        end
        realy_time_spans << [time_span.first,time_spans[i].last,book_record]
      else
        realy_time_spans << [time_span.first,time_span.last,nil]
      end
      i += 1
    end
    base_book_url = "#{new_book_record_path}?date=#{date.to_s(:db)}&court_id=#{court.id}"
    for realy_time_span in realy_time_spans
      book_url = "#{base_book_url}&start_hour=#{realy_time_span[0]}&end_hour=#{realy_time_span[1]}"
      hours = realy_time_span[1]-realy_time_span[0]
      li_height = 30*(hours) + (hours - 1)#*1
      unless (book_record = realy_time_span.last).nil?
        display_content =if book_record.order.member_type == Const::YES
                           "#{book_record.order.member_name}:#{book_record.order.member_card.card_serial_num}" 
                         else
                           "#{book_record.order.member_name}:无卡预定" 
                         end
        unless (coaches = book_record.order.coaches).blank?
          display_content << "(教练:#{coaches.map(&:name).join(',')})"
        end

        if book_record.order.has_bean_balanced?
          display_content << "(结算人: #{book_record.order.balance_record.who_balance.login})"
        end
        #display_content <<  "(#{book_record.status_desc})"
        url = if book_record.is_agented?
          "/book_records/#{book_record.id}/agent"
        else
          book_record.is_balanced? ? order_balance_path(book_record.order,book_record.order.balance_record) : edit_book_record_path(book_record)
        end
        li_class = []
        if book_record.is_booked?
          li_class << "book-reocrd-draggable"
          li_class << "book-reocrd-droppable"
        end
        title = "#{display_content}(#{book_record.status_desc})"
        info_htmls << [realy_time_span[0],content_tag(:li,content_tag("a",display_content,:href => url,
              :class =>book_record.status_color ,:title => title,
              :style => "height:#{li_height}px;display:block;"),:style => "height:#{li_height}px;",
            :class => li_class.join(' '), :id => "book-record-#{book_record.id}")]
      else
        if date < Date.today || (date == Date.today && realy_time_span[0] < DateTime.now.hour)
          unless current_user.can_book_when_time_due?
           info_htmls << [realy_time_span[0],content_tag(:li,
                                                         tag("input",{:type => 'button', :disabled => 'disabled',:value => '过 期', :class => "color02",:style => "height:#{li_height}px;"}))]

          else
          info_htmls << [realy_time_span[0],content_tag(:li,
                    tag("input",{:type => 'button',:href=> book_url,:value => '预定', 
              :class => "submit1 hand popup-new-window",:style => "height:#{li_height}px;"}))]
          end
        else
          info_htmls << [realy_time_span[0],content_tag(:li,content_tag("button",'预定',{:type => 'button', :href => book_url,
                                                                        :value => '预定',:class => "submit1 hand popup-new-window"  }))]
        end
      end
    end
    info_htmls.sort{|fst,scd| fst.first <=> scd.first}.map{|info_html| info_html.last}.join(' ').html_safe
  end

  def display_enable_buttons(book_record)

    db_book_record = book_record.new_record? ? book_record : BookRecord.find(book_record.id)

    buton_htmls = []

    db_book_record.new_record? and !db_book_record.is_to_do_agent? and buton_htmls << content_tag("button","预定",
                                                                                                  {:type => 'submit',:operation => :book,:class => 'submit1 hand'})

    db_book_record.should_application_to_agent? and buton_htmls << content_tag("button","申请代卖",{:type => 'button',
                                                                               :class => "data-agent-to-buy confirm submit1 hand",:conform_msg => "确认要变更为代卖预定么",:operation => :agent})

    db_book_record.should_to_agent_to_buy? and buton_htmls << content_tag("button","代卖",{:type => 'button',
                                                                          :class => "data-do-agent confirm submit1 hand",:conform_msg => "确认要代卖么",:operation => :do_agent})

    #db_book_record.is_to_do_agent? and buton_htmls << content_tag("button","代卖",{:type => 'submit confirm submit1 hand',
    #                                                              :operation => :do_agent,:conform_msg => ""})

    db_book_record.is_to_do_agent? and buton_htmls << content_tag("button","取消代卖",{:type => 'submit',
                                                                  :operation => :cancle_agent,:class => 'data-cancle-agent confirm submit1 hand',:conform_msg => "确认要取消代买么?"})

    db_book_record.should_to_cancle? and buton_htmls << content_tag("button","取消预定",{:type => 'button',
                                                                    :class => "data-cancle-booke confirm submit1 hand",:conform_msg => "确认要取消预定么？",:operation => :cancle})

    db_book_record.should_changed? and buton_htmls << content_tag("button","变更本次预定",{:type => 'button',
                                                                  :class => "data-change-booke confirm submit1 hand",:conform_msg => "确认要变更预定么？",:operation => :book})

    db_book_record.should_blance_as_expired?  and buton_htmls << content_tag("button","#{db_book_record.is_booked? ? '预定已过期，请结算' : '代买已过期，请结算'}",
                                                                             {:type => 'button',:class => "data-balance-order submit1 hand",:operation => :balance})

    db_book_record.should_to_active? and buton_htmls << content_tag("button","开场",{:type => 'button',
                                                                    :class => "data-active-booke confirm submit1 hand",:operation => :active,:conform_msg => "确认要开场？"})

    db_book_record.should_to_balance? and buton_htmls << content_tag("button","结算",
                                                                     {:type => 'button',:class => "data-balance-order submit1 hand",:operation => :balance})

    db_book_record.should_to_balance? and buton_htmls << content_tag("button","添加消费",{:type => 'button',
                                                                     :class => 'goods-list submit1 hand',:title => "商品列表",:rel => "goodslist",:href => '/goods/goods'})

    db_book_record.should_to_balance? and buton_htmls << content_tag("button","变更教练",{:type => 'button',
                                                                     :class => 'update-coaches confirm submit1 hand',:conform_msg => '确定要改变教练么?',:operation => 'change_coaches'})

    db_book_record.is_balanced? and  buton_htmls << content_tag("button","打印消费记录",{:type => 'button',:class => 'print-order-list submit1 hand'})
     (!db_book_record.new_record? ) and buton_htmls << content_tag("button","删除场地预定",{:type => 'button',:class => 'submit1 hand',:id => "delete_button" ,:bid => db_book_record.id})

    buton_htmls.join(' ').html_safe

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
