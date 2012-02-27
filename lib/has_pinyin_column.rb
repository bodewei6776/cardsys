require 'pinyin/pinyin'

module HasPinyinColumn
  extend ActiveSupport::Concern

  included do
    class_attribute :pinyin_fields_mapping
    self.pinyin_fields_mapping = {}
    class_attribute :pinyin_abbr_mapping
    self.pinyin_abbr_mapping = {}
    class_eval do
      before_validation :update_pinyin_fields
    end
  end

  module ClassMethods
    def set_pinyin_field(pinyin_field, chinese_field)
      self.pinyin_fields_mapping ||= {}
      self.pinyin_fields_mapping[pinyin_field] = chinese_field 
    end

    def set_abbr_field(pinyin_field, chinese_field)
      self.pinyin_abbr_mapping ||= {}
      self.pinyin_abbr_mapping[pinyin_field] = chinese_field 
    end
  end

  module InstanceMethods
    def update_pinyin_fields
      pinyin = PinYin.new
      self.class.pinyin_fields_mapping.each_pair do |k, v|
        next if self.send("#{v}").blank?
        self.send("#{k.to_s}=", pinyin.to_pinyin(self.send("#{v}")) )
      end

      self.class.pinyin_abbr_mapping.each_pair do |k, v|
        next if self.send("#{v}").blank?
        self.send("#{k.to_s}=", pinyin.to_pinyin_abbr(self.send("#{v}")) )
      end
    end
  end
end
