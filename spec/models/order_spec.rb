require 'spec_helper'

describe Order do
  describe "associations" do
    it { should belong_to(:member_card) }
    it { should belong_to(:user) }
    it { should have_one(:book_record) }
    it { should have_many(:order_items) }
  end

end
