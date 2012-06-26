# -*- encoding : utf-8 -*-
class CommonResource < ActiveRecord::Base

  has_many :common_resource_details,:dependent => :destroy

  CARD_TYPE = 'card_type'
  PERIOD_TYPE = 'period_type'
  COACH_TYPE = 'coach_type'
  CERT_TYPE = 'cert_type'
  GOOD_TYPE = 'good_type'
  LOCKER_TYPE = 'locker_type'
  GOOD_SOURCE = 'good_source'

  COACH_STATUS = 'coach_status'
  MEMBER_STATUS_ON = 1
  IS_MEMBER = 1
  IS_GRANTER = 0
  Type_Member,Type_Balance,Type_Counter= 1, 2, 3#会员卡 储值卡 记次卡
  Type_Member_Name,Type_Balance_Name,Type_Counter_Name,Type_Zige_Name = '会员卡', '储值卡', '记次卡','资格卡'#会员卡 储值卡 记次卡
  Catena_id_default = 1
  Gender_Man,Gender_Woman = 1,2 #1：男 2：女
  CARD_INIT, CARD_ON, CARD_OFF = 0, 1, 2
  MEMBER_CARD_ARREARS, MEMBER_CARD_EXPIRED, MEMBER_CARD_FREEZE, MEMBER_CARD_NORM =3, 2, 1, 0#3：欠费，2:过期，1：作废，0：正常
  COURT_OFF, COURT_ON = 0, 1

  MEMBER_CARD_NO_TEMP = 0

  PERIOD_TYPE_0, PERIOD_TYPE_1, PERIOD_TYPE_2 = 0, 1, 2 #0:winter, 1:summer, 2:vacation
  PERIOD_TYPE_1_MONTH = "times_summer"#summer month period
  PERIOD_TYPE_1_WEEK = (1..5)

  Winner_Tiem_Name_CHN  = '冬令时'
  Summer_Time_Name_CHN = '夏令时'
  Holiday_Time_Name_CHN = '节假日'

  PERIOD_START_TIME, PERIOD_END_TIME  = 7, 24#period start time and end time

  GOOD_ON, GOOD_OFF = 0, 1

  COACH_BOOK_STATUS_FREE = 0
  COACH_BOOK_STATUS_BOOKED = 1 # 0:free, 1:booked

  IS_HOLIDAY, IS_DAILY = 1, 0

  class << self
    def summer_months
      times_summer = CommonResource.create(:name => "times_summer")
      CommonResourceDetail.create(:common_resource_id => times_summer.id)
      times_summer = CommonResource.where(:name => CommonResource::PERIOD_TYPE_1_MONTH).first
      time_start,time_end = times_summer.detail_str.split(/\s+/)
      (time_start.to_i..time_end.to_i).to_a
    end

    def record_times
      all_record_times = []
      (7..24).each do |i|
        all_record_times[i] = 0
      end
      all_record_times
    end

    def is_summer_time?(date = Date.today)
      summer_time && summer_time.common_resource_details.map(&:detail_name).include?(date.mon.to_s)
    end

    def is_winter_time?(date = Date.today)
      winter_time && winter_time.common_resource_details.map(&:detail_name).include?(date.mon.to_s)
    end

    def is_weekend?(date = Date.today)
      !PERIOD_TYPE_1_WEEK.include?(date.wday)
    end

    def is_holiday?(date = Date.today)
      vacation = Vacation.where(["start_date <= :date and end_date >= :date",  {:date => date}]).first
      vacation ? vacation.is_holiday? : is_weekend?(date)
    end

    def date_type(date = Date.today)
      period_type = where(:name => "period_type").first
      return nil unless period_type
      unless is_holiday?(date)
        detail_name = is_summer_time?(date) ? Summer_Time_Name_CHN : Winner_Tiem_Name_CHN
        period_type.common_resource_details.where(:detail_name => detail_name).first
      else
        period_type.common_resource_details.where(:detail_name => Holiday_Time_Name_CHN).first
      end
    end

    def winter_time
      @winter_time ||= CommonResource.where(:name => "times_winter").first
    end

    def summer_time
      @summer_time ||= CommonResource.where(:name => "times_summer").first
    end

    def is_card_type?
      true
    end

    def good_types
      CommonResource.find_by_name("good_type").common_resource_details
    end

    def agent_to_buy_time
      CommonResource.find_by_name("agent_to_buy_time").detail_str.to_i rescue 1
    end

    def cancle_time
      CommonResource.find_by_name("cancle_time").detail_str.to_i rescue 24
    end

    def change_time
      CommonResource.find_by_name("change_time").detail_str.to_i rescue 0
    end

    def active_time
      CommonResource.find_by_name("active_time").detail_str.to_i rescue 30
    end

    def locker_due_time
      CommonResource.find_by_name("locker_due_time").detail_str.to_i rescue 7
    end

    def options_by_identifier(identifier)
      find_by_name(identifier).try(:common_resource_details)
    end
  end
end
