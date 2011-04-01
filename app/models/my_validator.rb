class MyValidator < ActiveModel::Validator
  # implement the method where the validation logic must reside
  def validate(record)
    
#    unless record.email.blank? || record.email =~/^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2] <<})$/
#    if !record.email.blank? && record.email =~/^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2]<<})$/
#      record.errors[:email] <<"电子邮件必须匹配电子邮件规则！"
#    end

#    if !record.birthday.blank? && !record.birthday =~/^([1-2]\d{3})-(0?[1-9]|10|11|12)-([1-2]?[0-9]|0[1-9]|30|31)/
#      record.errors[:birthday] <<"请输入正确的生日！"
#    end

#    if record.name.blank?
#      record.errors[:name] <<"会员名未填！"
#    end

#    if !record.name.blank? && record.name =~/^\w/
#      record.errors[:name] <<"会员名无效！"
#    end
    
#    if record.mobile.blank?
#      record.errors[:mobile] <<"手机号码为空！"
#    end

#    if !record.mobile.blank? && record.mobile.to_i(10) =~/^0{0,1}(13[0-9]|15[0-9])[0-9]{8}$/
#      record.errors[:mobile] <<"手机号码无效'1xxxxxxxxxx'！"
#    end
#    unless record.telephone.blank? || record.telephone =~/^\d{7] <<13}$/
#    if !record.telephone.blank? && record.telephone.to_i(10) =~/\d{3}-\d{8}|\d{4}-\d{7}/
#      record.errors[:telephone] <<"电话号码号码位数不正确！"
#    end
    if record.cert_type == 0
      if(!record.cert_num.blank? && (record.cert_num.to_i(10) =~/(^\d{15}$)|(^\d{17}([0-9]|X)$)/))
        record.errors[:cert_num] <<"身份证号码无效！"
      end
    elsif record.cert_type == 1
      if(!record.cert_num.blank? && record.cert_num.to_i(10) =~/\w{5,10}/)#/^\w{7]<<11}$/)
        record.errors[:cert_num] <<"护照号码未填或护照号码无效！"
      end
    else
      if (!record.cert_num.blank? && record.cert_num.to_i(10) =~/^\d{7}$/)
        record.errors[:cert_num] << "军人证号码未填或军人证号码无效！"
      end
    end
  end
end
