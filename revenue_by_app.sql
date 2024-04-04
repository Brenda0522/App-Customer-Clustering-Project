drop table if exists mapping1;
create table mapping1 as 
(select content_id, 'in-app_id' as type_of_id, type as purchasetype, parent_app_content_id as app_id
from "in-app_dat"
union
--since there is no type in add_dat we name it as download because it is from app_dat
select content_id, 'app_id' as type_of_id, 'download' as purchasetype, content_id as app_id
from "app_dat");
--test the new table
select * from mapping1;

drop table if exists mapping2;
create table mapping2 as
(select transaction_dat.*, mapping1.type_of_id, mapping1.purchasetype, mapping1.app_id
from mapping1
full outer join transaction_dat on mapping1.content_id = transaction_dat.content_id);
select * from mapping2;

drop table if exists mapping3;
create table mapping3 as
(select mapping2.*, app_dat.app_name
from mapping2
left join app_dat on app_dat.content_id = mapping2.app_id);
select * from mapping3;

drop table if exists revenue_by_app;
create table revenue_by_app as
(select app_name, sum(price) as revenue_per_app
from mapping3
group by app_name);
select * from revenue_by_app;
