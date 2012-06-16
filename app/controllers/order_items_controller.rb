# -*- encoding : utf-8 -*-
class OrderItemsController < ApplicationController

  def create
    @order = Order.find(params[:order_id])
    @order_item = @order.order_items.find_by_item_type_and_item_id(params[:order_item][:item_type],params[:order_item][:item_id]) || OrderItem.new(params[:order_item].merge(:order_id => @order.id))
    respond_to do |wants|
      if @order_item.update_attributes(params[:order_item])
        @order_item.set_price_for_good
        wants.html {  redirect_to goods_order_goods_path(@order) }
      else
        wants.html { redirect_to :back }
      end
    end
  end

  def update
    @order = Order.find(params[:order_id])
    @order_item = @order.order_items.find_by_item_type_and_item_id(params[:order_item][:item_type],params[:order_item][:item_id]) || @order.order_items.new(params[:order_item])
    respond_to do |wants|
      if @order_item.update_attributes(params[:order_item])
        @order_item.set_price_for_good
        wants.html {  redirect_to goods_order_goods_path(@order) }
      else
        wants.html { redirect_to :back }
      end
    end
  end

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
