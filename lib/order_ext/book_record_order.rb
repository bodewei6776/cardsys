module BookRecordOrder

  def order_errors
    @order_errors ||= []
  end

  def clear_order_errors
    order_errors.clear
  end

  def is_ready_to_order?(order)
    clear_order_errors
    is_court_ready_to_order?
    is_time_span_ready_to_order?
    is_status_ready_to_order?
  end

  def exist_conflict_record?
    conlict_record = conflict_record_in_time_span
    conlict_record && (original_book_reocrd.nil? && conlict_record.id != id  || original_book_reocrd.id != conlict_record.id)
  end

  def conflict_record_in_time_span
    conflict_record = self.class.where(:record_date => record_date,:court_id => court_id).where(["start_hour < :end_time AND end_hour > :start_time",
        {:start_time => start_hour,:end_time => end_hour}])
    conflict_record = conflict_record.where("id<>#{self.id}") unless new_record?
    conflict_record.first
  end
  
  private
  #TODO
  def is_court_ready_to_order?
    true
  end

  def is_time_span_ready_to_order?
    if end_hour  <= start_hour
      order_errors << I18n.t('order_msg.book_record.invalid_time_span')
    elsif  !is_to_do_agent? and exist_conflict_record? 
      order_errors << I18n.t('order_msg.book_record.exist_time_span',:date => record_date.to_s(:db),:start_time => start_hour,:end_time => end_hour)
    elsif is_to_do_agent? && (conlict_record = conflict_record_in_time_span)
      if is_a_valid_agented_record?(conlict_record)
        I18n.t('order_msg.book_record.invalid_agent',:start_time => conlict_record.start_hour,
        :end_time => conlict_record.end_hour)
      end
    end
  end

  #TODO   需要改进
  def is_status_ready_to_order?
    (new_record? && !should_book?) and order_errors << I18n.t('order_msg.book_record.invalid_status')
  end
  
end
