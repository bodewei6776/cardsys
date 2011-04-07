class MemberCardGranter < ActiveRecord::Base
  belongs_to :member
  belongs_to :granter,:class_name => "Member",:foreign_key => "granter_id"
  belongs_to :member_card


  state_machine :state, :initial => "enabled" do
    event :disable do
      transition :from => :enabled,:to => :disabled
    end

    event :enable do
      transition :from => :disabled,:to => :enabled
    end
  end
end
