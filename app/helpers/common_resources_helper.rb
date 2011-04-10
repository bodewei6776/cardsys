module CommonResourcesHelper
  def all_powers_tree(powers)
    html = "<ul class='tree'>"
    Power.all_tree_top.each do |parent| 
      html << "<li>"
      html << content_tag(:input,"",{:type => "checkbox",:name => "powers[]",:value => parent.id,:checked => powers.include?(parent) } )
      html << content_tag(:label,parent.subject)
      if parent.children.count > 0
        html << "<ul class='indent'>"
        parent.children.each do |child|
          html << "<li>"
          html << content_tag(:input,"",{:type => "checkbox",:name => "powers[]",:value => child.id,:checked => powers.include?(child),:parent_id => parent.id})
          html << content_tag(:label,child.subject)
          html << "</li>"
        end
        html << "</ul>"
      end
      html << "</li>"
    end
    html << "</ul>"
    html
  end
end
