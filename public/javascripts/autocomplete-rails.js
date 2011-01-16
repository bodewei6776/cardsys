/*
* Unobtrusive autocomplete
*
* To use it, you just have to include the HTML attribute autocomplete
* with the autocomplete URL as the value
*
*   Example:
*       <input type="text" autocomplete="/url/to/autocomplete">
*       
*/

$(document).ready(function(){
  $('input[autocomplete]').each(function(i){
    $(this).autocomplete({
      source: $(this).attr('autocomplete'),
      select: function(ui, li){
          var item = li.item;
          $(this).val(item.value)
          $("#search_form").submit();
        }
      });
  });
});

function orderAutocomplete(){
	$('input[order_autocomplete]').each(function(i){
		$(this).autocomplete({
	      source:  $(this).attr('order_autocomplete'),
	      select:  function(ui,li){
	        var item = li.item;
	        var reqest_url  = "/book_records/complete_member_infos?id=" + item.id;
	        $.get(reqest_url,function(returned_data)
	        {
	          $('#rel_member').html(returned_data);
	        });
	      }			
		});
	});
}