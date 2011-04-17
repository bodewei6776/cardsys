class OrderItemsController < ApplicationController
  
  def new
  end
  
  def create
  end
  
  # DELETE /courts/1
  # DELETE /courts/1.xml
  def destroy
    order_item = OrderItem.find(params[:id])
    order_item.destroy
    order = Order.find(params[:order_id])
    render :partial => "/orders/order_item", :locals => { :good_items => [],:order => order,:good => nil }
  end
  
  def batch_update
    order_items = []
    (params[:order_item]||[]).each do |order_item_attr|
      order_item = OrderItem.find(order_item_attr[:id])
      order_item.attributes = order_item_attr
      order_items << order_item
    end
    order = Order.find(params[:order_id])
    book_record = order.book_record
    errors = []
    order_items.each do |item|
      errors  << item.errors.full_messages.join('<br/>') unless item.save
    end
    render :text => (errors ? '修改成功' : errors.join('<br/>'))
 end
  
end
