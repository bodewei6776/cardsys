task :all_coaches_show => :environment do
    Coach.all.each do |c| 
      c.status = 1
      c.save
    end

end
