class Setting
  class << self
    def can_cancel_time_before_activate
      1.day
    end

    def can_book_time_before_book
     7.day 
    end

    def site_name
     "博德维"
    end

    def coach_types
     ["全职教练", "客人自带"] 
    end

    def cert_type_options(default_value)
    end
  end
end
