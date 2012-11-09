# -*- encoding : utf-8 -*-
class Setting
  class << self
    include ActionView::Helpers::FormOptionsHelper

    def minimum_warn_count
      2
    end

    def minimum_warn_amount
      1000
    end

    def can_cancel_time_before_activate
      1.day
    end

    def can_book_time_before_book
     7.day 
    end

    def site_name
       "国家网球中心"
    end

    def site_url
      "http://www.broadwell.cn"
    end

    def coach_types
     ["全职教练", "客人自带"] 
    end

    def cert_type_options(default_value)
       options_for_select(CommonResource.options_by_identifier("cert_type").collect{ |crd| [crd.detail_name, crd.id] }, default_value)
    end

    def good_source_options(default_value = 0)
       options_for_select(CommonResource.options_by_identifier("good_source").collect{ |crd| [crd.detail_name, crd.id] }, default_value)
    end


    def court_type_options(default_value)
       options_for_select(CommonResource.options_by_identifier("court_type").collect{ |crd| [crd.detail_name, crd.id] }, default_value)
    end

    def court_types
      CommonResource.options_by_identifier("court_type").collect{|c| [c.id, c.detail_name]}
    end

    def cert_type_detail_name(value)
      CommonResourceDetail.find(value).try(:detail_name) 
    end

    def good_source_name(value)
      CommonResourceDetail.find(value).try(:detail_name) 
    end

    def locker_type_options(default_value)
       options_for_select(CommonResource.options_by_identifier("locker_type").collect{ |crd| [crd.detail_name, crd.id] }, default_value)
    end

    # 是否支持条码扫描
    def barcode_scanner_enabled
      true
    end

    # 月开始时间
    def financial_begin_day_of_every_month
      25
    end

    def user_session_image
      #"user_session_new.jpg"
      "bdwuser_session_new.jpeg"
    end

  end
end
