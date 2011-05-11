module CategoriesHelper
  def operation_of_category(category)
    html = ""
    html += link_to("修改",edit_category_path(category))
    html += " | " 
    html += link_to("删除",category_path(category),:method => :delete)
    html 
  end
  def display_categories_tree
    html = ""
    Category.roots.each_with_index do |parent,index| 
      html << "<ul class='table_items'>"
      html << "<li class='w15'>" + index.succ.to_s + "</li>"
      html << "<li class='w20'> " + parent.name + "</li>"
      html << "<li class='w20'> " + operation_of_category(parent) + "</li>"
      html << "</ul>"
      if parent.children.count > 0
        parent.children.each_with_index do |child,index|
          html << "<ul class='table_items indent'> "
          html << "<li class='w15' style='text-align:right!important'>" + index.succ.to_s + "</li>"
          html << "<li class='w20'> " + child.name + "</li>"
          html << "<li class='w20'> " + operation_of_category(child) + "</li>"
          html << "</ul>"
        end
        html << "</ul>"
      end
    end
    html
  end

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
