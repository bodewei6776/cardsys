# -*- encoding : utf-8 -*-
require 'spec_helper'

describe MemberCard do
  describe "associations" do
    should_belong_to :card
    should_belong_to :member
    should_have_many :orders
  end
end
