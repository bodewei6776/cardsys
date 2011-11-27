class CoachBookRecord < BookRecord

  def coach
    resource
  end

  def conflict?
    !conflict_book_record.nil?
  end

  def conflict_book_record
    coach.book_records.where(:alloc_date => alloc_date).where(["start_hour < :end_time AND end_hour > :start_time",
                                                                {:start_time => start_hour,:end_time => end_hour}]).first
  end

  def to_s
    resource.name + "在" + start_time.to_chinese_mdh + "-"+ end_time.to_chinese_mdh + "之间被预约" 
  end
end
