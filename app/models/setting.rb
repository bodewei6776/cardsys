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
  end
end
