insert into common_resources(name, description, catena_id) values('card_type', '卡类型',0);
insert into common_resource_details(common_resource_id, res_detail_key, res_detail_value) values(1, 1, '会员卡');
insert into common_resource_details(common_resource_id, res_detail_key, res_detail_value) values(1, 2, '储值卡');
insert into common_resource_details(common_resource_id, res_detail_key, res_detail_value) values(1, 3, '计次卡');

insert into common_resources(name, description, catena_id) values('period_type', '令时',0);
insert into common_resource_details(common_resource_id, res_detail_key, res_detail_value) values(2, 1, '冬令时');
insert into common_resource_details(common_resource_id, res_detail_key, res_detail_value) values(2, 2, '夏令时');
insert into common_resource_details(common_resource_id, res_detail_key, res_detail_value) values(2, 3, '节假日');