# -*- encoding : utf-8 -*-
class CardPeriodPrice < ActiveRecord::Base
  belongs_to :card
  belongs_to :period_price
end
