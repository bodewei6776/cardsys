# -*- encoding : utf-8 -*-
# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define(:advanced_order) do |ao|
  ao.wday 1
  ao.start_date "2011-11-09"
  ao.end_date "2011-11-09"
  ao.start_hour 1
  ao.end_hour 1
end
