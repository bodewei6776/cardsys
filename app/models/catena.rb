class Catena < ActiveRecord::Base

  validates :telephone, :numericality => {:only_integer => true, :message => "电话号码必须为数字！", :allow_blank => true}, :length => {:minimum => 8, :maximum => 11, :message => "电话必须大于8位小于11位！", :allow_blank => true}
  #TODO
  def self.default
    first||create(:name => 'catena_1')
  end

end
