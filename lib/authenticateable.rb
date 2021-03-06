# -*- encoding : utf-8 -*-
#
#
module Authenticateable
  extend ActiveSupport::Concern

  included do
    class_attribute :validation_conditions
    self.validation_conditions = []

    class_eval do
      attr_accessor :login, :password, :user, :validate_in_condition_needed

      validates_presence_of :login, :message => "请填写账号", :if => :validate_in_condition
      validates_presence_of :password, :message => "密码不正确", :if => :validate_in_condition
      validate :login_password_match, :if =>  :validate_in_condition, :allow_blank => true

      def login_password_match
        return if self.errors.messages[:login] || self.errors.messages[:password]
        self.errors.add(:login, "账户不存在") unless User.find_by_login(self.login)
        self.errors.add(:password, "密码不正确") if User.find_by_login(self.login) && (not User.find_by_login(self.login).try(:valid_password?, self.password))
        self.user = User.find_by_login(self.login) if self.errors.messages.blank?
        self.who_balance = self.user if self.respond_to?:who_balance
      end

      def validate_in_condition
        #proc { |obj| validation_conditions.any?{ |c| c.call(obj) } }
        validate_in_condition_needed || validation_conditions.any?{ |c| c.call(self) } 
      end
    end
  end

  module ClassMethods
  end

end
