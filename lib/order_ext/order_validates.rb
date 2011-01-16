module OrderValidates

  def order_errors
    @order_errors ||= []
  end

  def clear_order_errors
    order_errors.clear
  end
  
end
