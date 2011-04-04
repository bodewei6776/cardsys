  decorator_path = File.join(Rails.root,"app","models","catena_decorator.rb")
  puts "loading " + decorator_path
  if Rails.env.production?
    require decorator_path
  else
    load decorator_path
  end
 
