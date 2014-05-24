every 1.day, :at => '4:30 am' do
  file_name = "cardsys#{Time.now.strftime('%Y_%m_%d')}"
  command "mysqldump -uroot -proot cardsys > #{file_name} && scp #{file_name} deploy@112.124.57.67:~/cardsys/ && rm #{file_name}"
end
