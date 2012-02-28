# -*- encoding : utf-8 -*-
module CourtsHelper

  def generate_coaches_options_for_courts(coaches,selected_value=nil)
    options = [['请选择教练','0']]
    coaches.each {|coach| options <<  ["#{coach.name}",coach.name]}
    options_for_select(options,selected_value.to_s)
  end
  
end
