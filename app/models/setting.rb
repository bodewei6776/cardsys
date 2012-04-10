# -*- encoding : utf-8 -*-
class Setting
  class << self
    include ActionView::Helpers::FormOptionsHelper

    def can_cancel_time_before_activate
      1.day
    end

    def can_book_time_before_book
     7.day 
    end

    def site_name
     "博德维"
    end


    def site_url
      "www.localhost:300"
    end
    def coach_types
     ["全职教练", "客人自带"] 
    end

    def cert_type_options(default_value)
       options_for_select(CommonResource.options_by_identifier("cert_type").collect{ |crd| [crd.detail_name, crd.id] }, default_value)
    end

    def good_source_options(default_value)
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

  end
end
