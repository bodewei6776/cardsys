# -*- encoding : utf-8 -*-
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

class Range
  def overlap_window_size(other_range)
    return 0 unless self.overlaps? other_range
    number_series = [self.first, self.last, other_range.first, other_range.last].sort 
    return number_series[2] - number_series[1]
  end
end

class Hash
  def deep_except(key)
    hash = {}
    each_pair do |k, v|
      next if k == key
      v = v.deep_except(key) if v.is_a? Hash
      hash[k] = v 
    end
    hash
  end
end

require 'has_column_state'
require 'has_pinyin_column'

