class BalanceItem < ActiveRecord::Base
  belongs_to :balance
  belongs_to :order_item
  belongs_to :order
end
