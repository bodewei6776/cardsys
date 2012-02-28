# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Order do
  describe "associations" do
    it { should belong_to(:member_card) }
    it { should belong_to(:user) }
    it { should belong_to(:member) }
    it { should have_many(:coach_book_records) }
    it { should have_one(:court_book_record) }
    it { should have_one(:non_member) }
    it { should have_many(:order_items) }
  end

end
