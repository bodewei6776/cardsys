module CurrentCatena

  def current_catena
    unless Thread.current[:current_catena]
      catena = Catena.find_by_id(1)  || Catena.new(:id => 1, :name => '连锁1')
      catena.id = 1 if catena.new_record?
      catena.save
      Thread.current[:current_catena] = catena
    end
    Thread.current[:current_catena]
  end
  
end

class ActiveRecord::Base
  
  extend CurrentCatena
  include CurrentCatena
  
  # class << self
  #   def #default_scope(scope_options = {})
  #      # wrap the scope into a lambda, evaluating the actual given conditions first
  #      self.default_scoping << lambda { 
  #        construct_finder_arel(scope_options.is_a?(Proc) ? scope_options.call : scope_options) }
  #    end
  # 
  #    def current_scoped_methods #:nodoc:"
  #      if m = scoped_methods.last and m.is_a?(Proc)
  #         unscoped(&m)
  #       else
  #         scoped_methods.last
  #       end
  #    end
  # end
  
end

