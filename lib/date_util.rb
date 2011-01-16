module DateUtil
  class << self
    #fomate date long
    def timelong(time)
      time.strftime('%Y-%m-%d %H:%M:%S') if time
    end
  
    def timelong_for_with_ling(time)
      time.strftime('%y-%m-%d %H:%M') if time
    end
  
    # format time to short style
    def timeshort(time)
      time.strftime('%Y-%m-%d') if time
    end
  
    def timeshort_without_this_year(time)
      if time
        time.year == Date.today.year ? time.strftime('%m/%d') : time.strftime('%m/%d/%y')
      end
    end
  
    # options
    # :start_date, sets the time to measure against, defaults to now
    # :date_format, used with <tt>to_formatted_s<tt>, default to :default
    def timeago(time, options = {})
      start_date = Time.now
      delta_minutes = (start_date.to_i - time.to_i).floor/60
      if delta_minutes.abs <= (8724*60) # eight weeks… I’m lazy to count days for longer than that
        distance = distance_of_time_in_words(delta_minutes);
        if delta_minutes < 0
          "#{distance} from now"
        else
          "#{distance} ago"
        end
      else
        if time.blank?
          return ""
        else
          return "on #{timelong(time)}"
        end
      end
    end

    def month_days(month)
     m_dates = [31,28,31,30,31,30,31,31,30,31,30,31]
     m_dates[month - 1]
    end

    def distance_of_time_in_words(minutes)
      case
      when minutes < 1
        "less than a minute"
      when minutes < 50
        pluralize(minutes, "minute")
      when minutes < 90
        "about one hour"
      when minutes < 1080
        "#{(minutes / 60).round} hours"
      when minutes < 1440
        "one day"
      when minutes < 2880
        "about one day"
      else
        "#{(minutes / 1440).round} days"
      end
    end  
  end

  def get_date_format_str(date)
    #puts date
    if date.nil? || date == ""
      return Time.now.at_beginning_of_day.strftime("%Y-%m-%d %H:%M:%S")
    else
      return date
    end
  end

  def parse_date(date)
    return nil if date.blank?
    res = ParseDate.parsedate(date)
    date = Time.local(*res)
  end
  
end