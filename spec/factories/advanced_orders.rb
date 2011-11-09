# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :advanced_order do
      wday 1
      start_date "2011-11-09"
      end_date "2011-11-09"
      start_hour 1
      end_hour 1
    end
end