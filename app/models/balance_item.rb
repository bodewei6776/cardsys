class BalanceItem < ActiveRecord::Base
  belongs_to :balance
  belongs_to :order_item
  belongs_to :order

  after_create :update_balance
  after_destroy :update_balance
  after_save :update_balance

  def update_balance
    self.balance.update_amount
  end

  def name
    self.order_item.name
  end
end
