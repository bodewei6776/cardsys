class Date
  def to_chinese_ymd
    self.strftime("%Y年%m月%d日")
  end
end

class Time
  def to_chinese_mdh
    self.strftime("%m月%d日%H时")
  end


  def to_chinese_ymd
    self.strftime("%Y年%m月%d日")
  end
end


require 'has_column_state'
require 'pinyin/pinyin'
