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


function userAutocomplete(){
	$('input[user_autocomplete]').each(function(i){
		$(this).autocomplete({
	      source:  $(this).attr('user_autocomplete'),
	      select:  function(ui,li){
	        var item = li.item;
                var reqest_url  = "/members/" + item.id + "/member_cards_list";
                $('#member_id').val(item.id);
                
	        $.get(reqest_url,function(returned_data)
	        {
                options = '';
                $(returned_data).each(function(i,node){ options +=("<option value='" + node.member_card.id +
                    "' order_tip_message='" + node.member_card.order_tip_message+ 
                    "' can_buy_good='" + node.member_card.can_buy_good+ 
                    "' member_info='" + node.member_card.member_info+ 
                    "' card_info='" + node.member_card.card_info+ 
                    "'>"
                    + node.member_card.card_serial_num + "</option>") 
                    });

                $('#cards select').html(options);
                $('#cards select').change(function(){
                  var selected = $(this).find("option:selected");
                  $('#member_card_info').text(selected.attr('card_info') + selected.attr('order_tip_message'));
                  $('#member_info').text(selected.attr('member_info'));
                  if(selected.attr('can_buy_good') == "no"){ $('#member_card_info').append("  [此卡不可消费商品]");}
                });
                $('#cards select').trigger("change");
	        });
	      }			
		});
	});
}



function goodAutocomplete(){
  $('input[good_autocomplete]').each(function(i){
    $(this).autocomplete({
      source:  $(this).attr('good_autocomplete'),
      select:  function(ui,li){
               var item = li.item;
               var sub_total = item.price;
               $('#price').text(item.price);
               $('#good_id').val(item.id);
               if($('#quantity').val() != "1"){
                sub_total = Number(item.price) * parseInt($('#quantity').val());
               }
               $('#sub_total').text(sub_total);
             }
    }		);	
  });
}
