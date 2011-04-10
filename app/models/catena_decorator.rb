ActiveRecord::Base.class_eval do
  class << self
    def catena_id_column
      @catena_id_column ||= [self.connection.quote_table_name(self.table_name), self.connection.quote_column_name("catena_id")].join('.')
    end

    def can_catena?
      self.column_names.include?("catena_id") 
    end

    def should_catena?
      can_catena? #&& !Catena.currently_default?
    end

    def relation_with_catena
      @relation = relation_without_catena
      if should_catena? && self.table_name != "users"
        @relation = @relation.where(["#{catena_id_column} is null or #{catena_id_column} = :catena_id", { :catena_id => Thread.current[:catena_id]}])
      end

      @relation
    end

    alias_method_chain :relation, :catena unless method_defined?(:relation_with_catena)
  end

  def can_catena?
    self.class.can_catena?
  end

  def should_catena?
    self.class.should_catena?
  end
  def before_with_catena
    if can_catena?
      self.catena_id = Thread.current[:catena_id]
    end
  end
  before_create :before_with_catena

end



