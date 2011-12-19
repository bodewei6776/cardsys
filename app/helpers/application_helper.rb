module ApplicationHelper

  def user_menus
    [
      {:image_offset => "1", :link => "/period_prices", :sub_menu => "common_menu", :display => "基础信息管理"},
      {:image_offset => "4", :link => "/members",       :sub_menu => "member_menu", :display => "会员管理"},
      {:image_offset => "3", :link => "/members/member_card_bind_index", :sub_menu => "member_card_menu", :display => "会员卡管理"},
      {:image_offset => "6", :link => "/orders", :sub_menu => "book_record_menu", :display => "场地预定"},
      {:image_offset => "2", :link => "/goods",        :sub_menu => "goods_menu", :display => "库存管理"},
      {:image_offset => "5", :link => "/reports/income", :sub_menu => "report_menu", :display => "分析报表"},
      {:image_offset => "7", :link => "/balances/new_good_buy", :sub_menu => "balance_menu", :display => "消费结算"},
      {:image_offset => "8", :link => "/rents", :sub_menu => "locker_menu", :display => "储物柜管理"},
      {:image_offset => "9", :link => "/users",  :sub_menu => "authorize_menu", :display => "权限管理"}
    ]
  end

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
      action_name.to_s != 'coach_status_search' && action_name.to_s != 'court_status_search' || (controller_name.to_s == "lockers" && action_name.to_s == "list")
  end

  def should_display_member_memu?
    %{members}.include?(controller_name.to_s) && (params[:p].nil?) && action_name.to_s != 'member_card_bind_index'
  end

  def should_display_member_card_memu?
    %{member_cards}.include?(controller_name.to_s) || action_name.to_s == 'member_card_bind_index'
  end

  def should_display_goods_memu?
    %{goods}.include?(controller_name.to_s) || controller_name.to_s == "categories"
  end

  def should_display_authorize_menu?
    controller_name =~ /users|department|catena/ && action_name.to_s != "change_password"
  end

  def should_display_balance_menu?
    controller_name =~ /balances|product_records/
  end

  def should_display_book_record_menu?
    action_name.to_s == 'coach_status_search' || action_name.to_s == 'court_status_search' ||
      controller_name.to_s =~ /orders|book_records|coaches|advanced_order/
  end

  def should_display_report_menu?
    controller_name == "reports"
  end

  def should_display_locker_menu?
    %{lockers rents}.include?(controller_name.to_s) && action_name.to_s != "list"
  end


  def should_display_system_menu?
    action_name.to_s == "change_password" || controller_name.to_s == "logs" || controller_name.to_s == "welcome"
  end

  def current_menu
    case
    when should_display_common_memu? then 'common_menu'
    when should_display_member_memu? then 'member_menu'
    when should_display_member_card_memu? then 'member_card_menu'
    when should_display_goods_memu? then 'goods_menu'
    when should_display_authorize_menu? then 'authorize_menu'
    when should_display_balance_menu? then 'balance_menu'
    when should_display_book_record_menu? then 'book_record_menu'
    when should_display_report_menu? then 'report_menu'
    when should_display_locker_menu? then 'locker_menu'
    when should_display_system_menu? then 'system_menu'
    end
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

  def generate_locker_type_options_without_all(locker_type)
    options = generate_res_options CommonResource::LOCKER_TYPE
    options_for_select(options, (locker_type.nil? || locker_type == "") ? '' : locker_type.to_i)
  end


  def generate_locker_type_options(locker_type)
    options = generate_res_options CommonResource::LOCKER_TYPE
    options << ['全部', '']
    options_for_select(options, (locker_type.nil? || locker_type == "") ? '' : locker_type.to_i)
  end

  def generate_good_type_options(good_type)
    #options = generate_res_options CommonResource::GOOD_TYPE
    #options << ['全部', '']
    #options_for_select(options, (good_type.nil? || good_type == "") ? '' : good_type.to_i)

    #"<option value='0'>全部</option>" + 
    #option_groups_from_collection_for_select(Category.roots,:children,:name,:id,:name,good_type)
    indent_category_options(good_type)
  end
  def generate_good_type_options_without_all(good_type)
    options = generate_res_options CommonResource::GOOD_TYPE
    options_for_select(options, (good_type.nil? || good_type == "") ? '' : good_type.to_i)
  end



  def generate_good_type_str(type)
    #get_res_item(CommonResource::GOOD_TYPE, type)
    category = Category.find(type)
    category.parent.name + " / " + category.name
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
    granter_ids = MemberCardGranter.where(:member_id => member.id)
    for granter in granter_ids
      options << granter.granter_id
    end
    granters = []
    Member.where(["id IN(?)", options]).each { |memb| granters << [memb.name, memb.id] }
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
    header = content_tag(:ul, header_items.join(' '), :class => "bttitle black fb")
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
    table = content_tag(:ul, header_items.join(" "), :class => "bttitle black fb") + body_items.join(",")
    table.html_safe
  end

  def display_notice_div(title,msg)
    return "" if title.blank? || msg.blank?
    content_tag(:div, content_tag(:h2, title) + content_tag(:ul, msg), :id => "errorExplanation", :class => "errorExplanation")
  end


  def powers_tree(powers)
    html = "<ul class='tree'>"
    Power.tree_top.each do |parent| 
      html << "<li>"
      html << content_tag(:input,"",{:type => "checkbox",:name => "powers[]",:value => parent.id,:checked => powers.include?(parent) } )
      html << content_tag(:label,parent.subject)
      if parent.children_without_hide.count > 0
        html << "<ul class='indent'>"
        parent.children_without_hide.each do |child|
          html << "<li>"
          html << content_tag(:input,"",{:type => "checkbox",:name => "powers[]",:value => child.id,:checked => powers.include?(child),:parent_id => parent.id})
          html << content_tag(:label,child.subject)
          html << "</li>"
        end
        html << "</ul>"
      end
      html << "</li>"
    end
    html << "</ul>"
    html
  end

  def chinese_week_day(offset)
    week_days = %w{星期日 星期一 星期二 星期三 星期四 星期五 星期六} 
    week_days[offset]
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


  def days_in_month(year, month)
    date = Date.new(year, month, -1)
    if date.beginning_of_month == Date.today.beginning_of_month
      Date.today.day
    else
      date.day
    end
  end


  def menus_map
    {
      :common_menu => "基础信息管理",
      :member_menu => "会员管理",
      :member_card_menu => "会员卡管理",
      :goods_menu => "商品库存管理",
      :report_menu => "分析报表",
      :book_record_menu => "场地预定",
      :balance_menu => "消费预算",
      :locker_menu => "储物柜管理",
      :authorize_menu => "权限管理",
      :system_menu => "系统管理"
    }
  end

  def current_catena
    OpenStruct.new(:name => "博德维")  
  end

  def chinese_date(date = Date.today)
    date.strftime("%Y年%m月%d日") 
  end

  def back_to(path)
    concat(link_to "返回", path)
  end

  def state_in_chinese(state)
    return "未知" if state.nil?
    {"disable" => "禁用", "enable" => "正常"}[state]
  end

  def current_catena_name
    "博德维"
  end
end
