ActiveRecord::Base.class_eval do
  class << self
    def catena_id_column
      @catena_id_column ||= [self.connection.quote_table_name(self.table_name), self.connection.quote_column_name("catena_id")].join('.')
    end

    def can_catena?
      self.column_names.include?("catena_id")
    end

    def should_catena?
      can_catena? && !Catena.currently_default?
    end

    def add_conditions_with_catena!(sql, conditions, scope = :auto)
      scope = scope(:find) if :auto == scope
      conditions = [conditions]
      conditions << scope[:conditions] if scope
      conditions << type_condition if finder_needs_type_condition?
      conditions << ["#{catena_id_column} is null or #{catena_id_column} = :catena_id", { :catena_id => Catena.default_id }] if should_catena?
      merged_conditions = merge_conditions(*conditions)
      sql << "WHERE #{merged_conditions} " unless merged_conditions.blank?
    end

    alias_method_chain :add_conditions!, :catena unless method_defined?(:add_conditions_without_catena!)
  end

  def can_catena?
    self.class.can_catena?
  end

  def should_catena?
    self.class.should_catena?
  end

  def before_create_with_catena
    before_create_without_catena
    if can_catena?
      self.catena_id ||= Catena.default_id
    end
  end

  alias_method_chain :before_create, :catena unless method_defined?(:before_create_without_catena)
end
