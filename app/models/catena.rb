class Catena < ActiveRecord::Base

  validates :name,:presence => true
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
