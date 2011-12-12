class Date
  def timeshort
    self.strftime("%Y年%m月%d日")
  end
end

class Time
  def to_chinese_mdh
    self.strftime("%m月%d日%H点")
  end
end

class String
end
