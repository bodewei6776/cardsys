class Catena < ActiveRecord::Base

#  validates :telephone, :numericality => {:only_integer => true, :message => "电话号码必须为数字！", :allow_blank => true}, :length => {:minimum => 8, :maximum => 11, :message => "电话必须大于8位小于11位！", :allow_blank => true}

  validates :name,:presence => true
 # validates :contact,:presence => true
  has_and_belongs_to_many :users
  class << self
    def current=(catena)
      Thread.current[:catena] = catena
      Thread.current[:catena_id] = Thread.current[:catena].id if Thread.current[:catena]
    end

    def currently_default?
      default_id == default_catena_id
    end

    def default
      Thread.current[:catena] || default_catena
    end

    def default_id
      Thread.current[:catena_id] || default.id
    end

    def default_catena
      @default_catena ||= find_or_create_by_name('连锁一店')
    end

    def default_catena_id
      @default_catena_id ||= default_catena.id
    end

    def reset
      Thread.current[:catena] = nil
      Thread.current[:catena_id] = nil
    end
  end

end
