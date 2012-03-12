# -*- encoding : utf-8 -*-
module CategoriesHelper

  def indent_category_options(selected = nil)
    options = "<option value='0'>全部</option>" 
    Category.roots.each do |parent|
      options << "<option value='#{parent.id}' #{selected == parent.id.to_s ? "selected" : ""}> " + parent.name + "</option>"
      parent.children.each do |child|
        options << "<option value='#{child.id}' #{selected == child.id.to_s ? "selected" : ""}>- " + child.name + "</option>"
      end
    end
    options
  end
end
