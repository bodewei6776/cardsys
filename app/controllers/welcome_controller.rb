class WelcomeController < ApplicationController
  layout 'main'
  def backup
    @backups = Dir.glob(File.join(Rails.root , "/public/back_dbs/*")).reverse
  end

  def backup_db
    file_name = File.join(Rails.root , "public" , "back_dbs" , "sql_" + rand(100).to_s )
    file_name << ".sql"
    username= ActiveRecord::Base.connection.instance_variable_get("@config")[:username]
    password = ActiveRecord::Base.connection.instance_variable_get("@config")[:password]
    database = ActiveRecord::Base.connection.instance_variable_get("@config")[:database]
    
    #backup_script = "mysqldump -u#{username} -p#{password} #{database} > #{file_name}"
    backup_script = "mysqldump -u#{username}  #{database} > #{file_name}"
    system(backup_script)
    redirect_to backup_path
  end

  def delete_backup
    system("rm #{params[:name]}")
    redirect_to backup_path
  end

  def about
  end

end
