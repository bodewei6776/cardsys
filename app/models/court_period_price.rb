# -*- encoding : utf-8 -*-
class CourtPeriodPrice < ActiveRecord::Base
  belongs_to :court
  belongs_to :period_price
end
