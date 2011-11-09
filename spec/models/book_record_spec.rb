require 'spec_helper'

describe BookRecord do
  describe "association"do
    it { should belong_to :order }
  end
end
