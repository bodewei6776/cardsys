# -*- encoding : utf-8 -*-
module HashColumnState
  def self.included(base)
    base.class_eval do
      scope :enabled, where(:state => "enabled")
      before_validation(:on => :create) do 
        self.state = 'enabled'
      end
    end
  end

  def state_desc
    {"disabled" => "禁用", "enabled" => "启用"}[self.state] || "未知"
  end

  def disabled?
    state == "disabled"
  end

  def enabled?
    state == "enabled"
  end

  def switch_state!
    self.state = (disabled? ? "enabled" : "disabled")
    self.save(:validate => false)
  end
end
