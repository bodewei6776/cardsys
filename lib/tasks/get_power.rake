task :get_power => :environment do

  def t(s,scope)
    I18n.t(s,:scope => scope)
  end
  Power.delete_all
  Dir.glob("#{Rails.root}/app/controllers/*.rb").sort.each { |file| require_dependency file }
  #Dir.glob("#{Rails.root}/app/models/*.rb").sort.each { |file| require_dependency file }
  ApplicationController.subclasses.each do |c|
    c.action_methods.each do |a|
      Power.create(:subject => (t(c.to_s,"controllers") + " | " + t(a,"actions")),
                   :controller => t(c.to_s,"controllers"),:action => t(a,"actions"),:description => (t(c.to_s,"controllers") + " | " + t(a,"actions")))
    end
  end
end
