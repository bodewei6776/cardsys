class BalanceItem < ActiveRecord::Base
  belongs_to :balance
  belongs_to :order_item
  belongs_to :order

  after_create :update_balance
  after_destroy :update_balance
  after_update :update_balance

  def update_balance
    hash = {}
    self.balance.update_attributes(hash)
  end
end
