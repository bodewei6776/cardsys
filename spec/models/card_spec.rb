# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Card do
  should_have_many :member_cards
  should_have_many :card_period_prices
  should_validate_presence_of :name
end
