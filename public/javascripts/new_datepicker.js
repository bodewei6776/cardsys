(function ($) {
  $.fn.new_datepicker = function (options) {
    return this.each(function () {
      $(this).click(function(){
        WdatePicker({eCont:$(this).get(0),onpicked:function(dp){}, lang:"zh-cn",isShowToday:true})
      });
    });
  };
})(jQuery);


