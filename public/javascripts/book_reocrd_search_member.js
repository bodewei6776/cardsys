 $(document).ready(function() {
    $("#order_member_name").autocomplete({url: "/book_records/complete_for_members",
      showResult: function(value, data) {
        return '<span style="color:red">' + value + '</span>';
      }
    })
    $("#order_member_name").autocomplete("/book_records/complete_for_members",
    { parse: function(data){
        return $.map(eval(data), function(item) {
          return {
            data: item,
            value: item.name,
            result: item.name
          }
        });
      },
      formatItem: function(item){
        return item['name'] + ' ' + item['mobile'];
      },
      scroll: true }).result(function(event, data, formatted) {
        var url  = "/book_records/complete_member_infos?member_name=" + encodeURIComponent(data.name) + '&mobile=' +  data.mobile;
        $.get({url: url});
    });
  });
