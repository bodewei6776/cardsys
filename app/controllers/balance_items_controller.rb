class BalanceItemsController < ApplicationController
  before_filter :find_balance_item

  def update_real_price
    @balance_item.update_attribute(:real_price, params[:real_price])
    render :nothing => true
  end
  
  def update_discount_rate
    @balance_item.update_attribute(:discount_rate, params[:discount_rate])
    @balance_item.update_attribute(:real_price, @balance_item.price * @balance_item.discount_rate)
    render :nothing => true
  end

  def find_balance_item
    @balance_item = BalanceItem.find(params[:id])
  end
end
