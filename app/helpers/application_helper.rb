module ApplicationHelper

  def error_messages_for(object_name, options = {})
    options = options.symbolize_keys
    object = instance_variable_get("@#{object_name}")
    unless object.errors.empty?
      error_lis = []
      object.errors.each{ |key, msg|
        error_lis << msg+" "
      }
      content_tag("div", content_tag(options[:header_tag] || "h2", "发生#{object.errors.count}个错误" ) + content_tag("br") + content_tag("ul", error_lis), "id" => options[:id] || "errorExplanation", "class" => options[:class] || "errorExplanation" )
    end
  end

  def should_display_common_memu?
    %{period_prices tennis_courts courts coaches cards common_resources vacations}.include?(controller_name.to_s) &&
      action_name.to_s != 'coach_status_search' && action_name.to_s != 'court_status_search'
  end

  def should_display_member_memu?
    %{members}.include?(controller_name.to_s) && (params[:p].nil?) && action_name.to_s != 'member_card_bind_index'
  end

  def should_display_member_card_memu?
    %{member_cards}.include?(controller_name.to_s) || action_name.to_s == 'member_card_bind_index'
  end

  def should_display_goods_memu?
    %{goods}.include?(controller_name.to_s)
  end

  def should_display_authorize_menu?
    controller_name =~ /users|department/
  end

  def should_display_balance_menu?
    controller_name =~ /balances|product_records/
  end

  def should_display_book_record_menu?
    action_name.to_s == 'coach_status_search' || action_name.to_s == 'court_status_search' ||
      controller_name.to_s =~ /book_records|coaches|advanced_order/
  end

  def should_display_report_menu?
    false
  end

  def display_current_menu
    current_menu = case
    when should_display_common_memu? then 'common_memu'
    when should_display_member_memu? then 'member_memu'
    when should_display_member_card_memu? then 'member_card_memu'
    when should_display_goods_memu? then 'goods_memu'
    when should_display_authorize_menu? then 'authorize_menu'
    when should_display_balance_menu? then 'balance_menu'
    when should_display_book_record_menu? then 'book_record_menu'
    when should_display_report_menu? then 'report_menu'
    end
    js =<<js
    <script type="text/javascript">
    $('.menu_item').hide();
    $('##{current_menu}').show();
    </script>
js
    js.html_safe
  end

  def generate_card_type_options(card)
    options = generate_res_options CommonResource::CARD_TYPE
    options_for_select(options, card.card_type)
  end

  def generate_card_status_options(selected_value)
    options = [['所有状态','-1'],['使用中','1'],['未使用','0'],['已停用','2'],['已注销','3']]
    options_for_select(options,selected_value)
  end

  def display_card_type_desc(card)
    return "" if card.nil?
    get_res_item(CommonResource::CARD_TYPE, card.card_type)
  end

  def card_time_span_available(card, span)
    card.available_on(span) ? "可用" : "不可用"
  end

  def generate_period_price_type_options(period_price)
    options = generate_res_options CommonResource::PERIOD_TYPE
    options_for_select(options, period_price.period_type)
  end
  
  def display_period_price_type_desc(period_price)
    get_res_item(CommonResource::PERIOD_TYPE, period_price)
  end

  def generate_time_options(checked_time)
    options = []
    for i in 1..24
      options << [i.to_s + ":00", i]
    end
    options_for_select(options, checked_time ? checked_time : nil)
  end

  def generate_time_str(time)
    time.to_s + ":00"
  end

  def generate_coach_type_options(coach)
    options = generate_res_options CommonResource::COACH_TYPE
    options_for_select(options, coach.coach_type ? coach.coach_type.to_s : nil)
  end

  def generate_coach_type_str(type)
    get_res_item(CommonResource::COACH_TYPE, type)
  end

  def generate_cert_type_options(model)
    options = generate_res_options CommonResource::CERT_TYPE
    options_for_select(options, model.cert_type.nil? ? model.cert_type : 0)
  end

  def generate_cert_type_str(type)
    get_res_item(CommonResource::CERT_TYPE, type)
  end

  def generate_good_type_options(good_type)
    options = generate_res_options CommonResource::GOOD_TYPE
    options << ['全部', '']
    options_for_select(options, (good_type.nil? || good_type == "") ? '' : good_type.to_i)
  end

  def generate_good_type_str(type)
    get_res_item(CommonResource::GOOD_TYPE, type)
  end

  def generate_good_source_options(model)
    options = generate_res_options CommonResource::GOOD_SOURCE
    options_for_select(options, !model.good_source.nil? ? model.good_source : 0)
  end

  def generate_good_source_str(source)
    get_res_item(CommonResource::GOOD_SOURCE, source)
  end

  def generate_granter_options(member)
    options = []
    granter_ids = MemberCardGranter.where(:catena_id => member.catena_id).where(:member_id => member.id)
    for granter in granter_ids
      options << granter.granter_id
    end
    granters = []
    Member.where(["id IN(?)", options]).where(:catena_id => member.catena_id).each { |memb| granters << [memb.name, memb.id] }
    granters
  end

  def generate_court_status_str(status)
    CommonResource::COURT_ON == status ? '启用' : '停用'
  end

  def get_user_name(id)
    id.blank? ? "" : User.find(id).user_name
  end

  def generate_catena_options
    options = []
    Catena.all.each{|x|options << [x.name, x.id]}
    options_for_select(options, 1)#TODO
  end

  def member_card_status_str card_status
    (CommonResource::MEMBER_CARD_FREEZE == card_status) ? "已作废" : "正常"
  end

  def ftime(time)
    return '' if time.nil?
    return time.strftime("%Y年%m月%d日 %H点%M分")
  end

  def ftime_date(time)
    return '' if time.nil?
    return time.strftime("%Y-%m-%d")
  end

  def gender_desc(gender)
    gender == 1 ? '男' : '女'
  end

  def get_coach_avater
    image = MiniMagick::Image.from_file("/coach/william.jpg")
    image.resize "400X300"
    image.write("william_medium.jpg")
  end

  def generate_department_options(model)
    options = []
    Department.all.each{|x| options << [x.name, x.id]}
    options_for_select(options, model.department.nil? ? 1 : model.department.id)
  end

  #column_options => {:name => {:class => xx,:chn => '',:formater => }}
  def dispay_as_table(objects,columns,column_options)
    header_items = []
    columns.each do |column|
      css_klass = column_options[column][:class]
      column_chn = column_options[column][:chn]
      header_items << "<li class='#{css_klass}'>#{column_chn}</li>"
    end
    header = <<tb_header
    <ul class="bttitle black fb ">
          #{header_items.join('')}
    </ul>
tb_header
    body_items = []
    objects.each do |object|
      columns.each do |column|
        css_klass = column_options[column][:class]
        display_value = if !(formater = column_options[column][:formater]).blank?
          send(formater,object,column)
        else
          object.send(column)
        end
        body_items << "<ul class='table_items'><li class='#{css_klass}'>#{display_value}</li></ul>"
      end
    end
    table = <<tbl
    <ul class="bttitle black fb ">
       #{header_items.join('')}
    </ul>
    #{body_items.join(',')}
tbl
    table.html_safe
  end
  
  def display_notice_div(title,msg)
    return "" if title.blank? || msg.blank?
    info = <<notice
    <div id="errorExplanation" class="errorExplanation">
	   <h2>#{title}</h2><br>
	   <ul>#{msg}</ul>
</div>
notice
    info.html_safe
  end

  private

  def generate_res_options res_type
    com_res = CommonResource.where(:name => res_type).last
    options = []
    com_res.common_resource_details.each{|x|
      options << [x.detail_name, x.id]
    }
    options
  end

  def get_res_item(res_type, option_key)
    r_detail = ""
    com_res = CommonResource.where(:name => res_type).last
    com_res.common_resource_details.each{|x|
      if x.id == option_key        
        r_detail = x.detail_name
      end
    }
    r_detail
  end

end