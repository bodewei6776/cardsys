# -*- encoding : utf-8 -*-
require 'spec_helper'

describe BookRecord do
  it { should belong_to :order }
  it { should belong_to :resource }
  it { should validate_numericality_of(:start_hour).with_message("开始时间必须为整数")}
  it { should validate_numericality_of(:end_hour).with_message("结束时间必须为整数")}
end
