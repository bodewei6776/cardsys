(function ($) {
  $.fn.new_datepicker = function (options) {
    return this.each(function () {
      $(this).click(function(){
        WdatePicker({onpicked:function(dp){}, lang:"zh-cn",isShowToday:true})
      });
    });
  };
})(jQuery);


