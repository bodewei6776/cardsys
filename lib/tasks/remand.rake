task :remand => :environment do
  BookRecord.all.each do |b|
    puts b.id
    puts b.order.nil?
    b.destroy if b.order.nil?
  end
end
