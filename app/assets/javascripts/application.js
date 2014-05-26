//= require jquery
//= require jquery.ui.all
//= require autocomplete-rails
//= require jquery.colorbox-min
//= require jquery.tokeninput
//= require rails
//= require cookie 
//= require bootstrap-alert
//= require bootstrap-tab
//= require bootstrap-tooltip




$(document).ready(function(){
  $('a[href='+ $.cookie('activetab') +']').tab('show');
  $('a[data-toggle="tab"]').on('shown', function (e) {
		$.cookie('activetab', e.target.hash,{expires: 70 * 100 * 100 * 100});
  })

  $('a').tooltip({"placement":"right"});
  $('.alert').fadeOut(6 * 1000);
});


/* Chinese initialisation for the jQuery UI date picker plugin. */
/* Written by Cloudream (cloudream@gmail.com). */
jQuery(function($){
  $.datepicker.regional['zh-CN'] = {
    closeText: '关闭',
    prevText: '&#x3c;上月',
    nextText: '下月&#x3e;',
    currentText: '今天',
    monthNames: ['一月','二月','三月','四月','五月','六月',
      '七月','八月','九月','十月','十一月','十二月'],
      monthNamesShort: ['1','2','3','4','5','6',
        '7','8','9','10','11','12'],
        dayNames: ['星期日','星期一','星期二','星期三','星期四','星期五','星期六'],
        dayNamesShort: ['周日','周一','周二','周三','周四','周五','周六'],
        dayNamesMin: ['日','一','二','三','四','五','六'],
        weekHeader: '周',
        dateFormat: 'yy-mm-dd',
        firstDay: 7,
        isRTL: false,
        showMonthAfterYear: true,
        yearSuffix: ''};
        $.datepicker.setDefaults($.datepicker.regional['zh-CN']);
});


