require 'erb'

desc "migrate from cardsys_dev db"

#TODO
# add old_id column dynamiclly
# relationship. remove old_id
task :migrate_old_db => :environment do

  count = {}

  Dir["#{Rails.root}/app/models/**/*"].each do |model_file|
    next if File.directory?(model_file)
    require model_file
  end

  (ActiveRecord::Base.send :subclasses).each do |model|
    begin
      old_db = YAML.load(ERB.new(File.read("#{Rails.root}/config/database.yml")).result)["old"]
      new_db = YAML.load(ERB.new(File.read("#{Rails.root}/config/database.yml")).result)["devlelopment"]
      old_connection = model.connection
      model.establish_connection old_db
      next if %(Order OrderItem Balance BalanceItem BookRecord Log).include?model.name
      next unless model.table_exists?
      datas = model.all 
      model.establish_connection new_db
      datas.each do |data|
        begin
          record = model.new(data.attributes.slice(*model.column_names))
          record.id = data.attributes["id"]
          ap record
          ap record.save!(false)
        rescue Exception => e
          if count[model.name]
            count[model.name] += 1
          else
            count[model.name] = 1
          end
          ap count
        end
      end

    end
  end

  ap count
end
