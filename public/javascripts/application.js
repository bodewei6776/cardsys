function show_member()
{
    var sn = $("#card_serial_num").value;
    if (sn == "" || sn == null)
    {
        alert("请输入卡号");
        return;
    }
    var url = '/cards/ajax_member';
    url += ('sn=' + sn);
    $.get({
        url: url,
        success: function(data){
            $("#rel_member").text(data)
        }
    });
}

function complete_book_form(element){
    query_member_card(element,'/book_records/search_member_info');
}

function complete_memner_card(element){
    query_member_card(element,'/product_records/search_member_info');
}

function query_member_card(element,url){
    var searchParams = $(element).val().split(';')
    url = url + "?member_name=" + encodeURIComponent(searchParams[0]) + "&phone="+searchParams[1];
    $.get({
        url: url
    });
}

function search_product_by_type(type_id){
    var url = "/product_records/search_product_type?type_id=" + type_id
    $.get({
        url: url
    });
}

function change_product(product_id){
    var url = '/product_records/'+product_id+'/change_product'
    $.get({
        url: url
    });
}

function change_stand_amount(product_id,end_hour){
    var url = '/book_records/'+product_id+'/calculate_book_amount?end_hour=' + end_hour;
    $.get({
        url: url
    });
}

function change_card_by_number(card_number){
    var url = '/book_records/change_card?card_nmber=' + card_number;
    $.get(url,function(returned_data)
    {
        $('#rel_member').html(returned_data);
    });
}

function change_card(card_id){
    var url = '/product_records/change_card?card_id=' + card_id;
    $.get({
        url: url
    });
}

function radio_togle(radio,_id){
    var disabled = (!($(radio).val() == '1' && $(radio).attr('checked') == 'checked') ? 'disalbed' : 'enabled')
    $("#"+_id).attr('disabled',disabled);
}



(function($){ 		  
    $.fn.popupWindow = function(instanceSettings){
    }})
	
