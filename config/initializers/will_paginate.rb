module WillPaginate  
  module ViewHelpers
    class I18nRender < LinkRenderer  
      def prepare(collection, options, template)  
        options[:previous_label] = "上一页"# I18n.translate("will_paginate.previous_label")  
        options[:next_label] = "下一页"#I18n.translate("will_paginate.next_label")  
        super  
      end  
    end  
  end  
end

WillPaginate::ViewHelpers.pagination_options[:renderer] = "WillPaginate::ViewHelpers::I18nRender"  

