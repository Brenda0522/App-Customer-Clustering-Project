-- Code Here

--combine the in app purchase and app purchase together
--create a new column and record both
--two tables in union must have the same format in commandline
drop table if exists mappingtable;
create table mappingtable as 
(select content_id, 'in-app_id' as type_of_id, type as purchasetype, parent_app_content_id as app_id
from "in-app_dat"
union
--since there is no type in add_dat we name it as download because it is from app_dat
select content_id, 'app_id' as type_of_id, 'download' as purchasetype, content_id as app_id
from "app_dat");
--test the new table
select * from mappingtable;

--join app_dat on mappingtable 
drop table if exists mappingtable2;
create table mappingtable2 as
--all columns from mappingtable and category_id & device_id from app_dat
(select mappingtable.*, app_dat.category_id, app_dat.device_id 
from mappingtable
left join app_dat on mappingtable.app_id = app_dat.content_id);
--test the new table
select * from mappingtable2;

--join device_ref on mappingtable2
drop table if exists mappingtable3;
create table mappingtable3 as
--all columns from mappingtable2 and device_name from devide_ref
(select mappingtable2.*, device_ref.device_name 
from mappingtable2
left join device_ref on mappingtable2.device_id = device_ref.device_id);
--test the new table
select * from mappingtable3;

--join category_ref on mappingtable3
drop table if exists mappingtable4;
create table mappingtable4 as
(select m3.content_id, m3.type_of_id, m3.purchasetype, m3.app_id, m3.device_name, category_ref.category_name
from mappingtable3 as m3
left join category_ref on m3.category_id = category_ref.category_id);
--test the new table
select * from mappingtable4;

--join transaction_dat and account_dat together
drop table if exists transaction_dat2;
create table transaction_dat2 as
--all columns from transaction_dat and create_dt & payment_type from account_dat 
--change the column name of "create_dt" to "acct_dt" to avoid repetitive names
(select a.*, b.create_dt as "acct_dt", b.payment_type 
from transaction_dat as a
left join account_dat as b on a.acct_id = b.acct_id);
--test the new table
select * from transaction_dat2;

--create the final version of the overall table 
--join transaction_dat2 and mappingtable4 together
drop table if exists finaltable;
create table finaltable as
select a.*, b.type_of_id, b.purchasetype, b.app_id, b.device_name, b.category_name
from transaction_dat2 as a
left join mappingtable4 as b on a.content_id = b.content_id;
--test the new table
select * from finaltable;
select count(*) from finaltable;


-- Data Analysis Here

--find the number of transaction by category
select count(*) from finaltable where finaltable.category_name = 'Utilities';
select count(*) from finaltable where finaltable.category_name = 'Photos & Videos';
select count(*) from finaltable where finaltable.category_name = 'Entertainment';
select count(*) from finaltable where finaltable.category_name = 'Games';
select count(*) from finaltable where finaltable.category_name = 'Social Networking';

--find the number of transaction by purchasetype
select count(*) from finaltable where finaltable.purchasetype = 'download' 
group by purchasetype;
select count(*) from finaltable where finaltable.purchasetype = 'consumable' 
group by purchasetype;
select count(*) from finaltable where finaltable.purchasetype = 'subscription' 
group by purchasetype;

--find the number of downloads by category
select count(*) from finaltable where finaltable.category_name = 'Utilities' and finaltable.purchasetype = 'download'
group by category_name, purchasetype;
select count(*) from finaltable where finaltable.category_name = 'Photos & Videos' and finaltable.purchasetype = 'download'
group by category_name, purchasetype;
select count(*) from finaltable where finaltable.category_name = 'Entertainment' and finaltable.purchasetype = 'download'
group by category_name, purchasetype;
select count(*) from finaltable where finaltable.category_name = 'Games' and finaltable.purchasetype = 'download'
group by category_name, purchasetype;
select count(*) from finaltable where finaltable.category_name = 'Social Networking' and finaltable.purchasetype = 'download'
group by category_name, purchasetype;

--find the number of consumables by category
select count(*) from finaltable where finaltable.category_name = 'Utilities' and finaltable.purchasetype = 'consumable'
group by category_name, purchasetype;
select count(*) from finaltable where finaltable.category_name = 'Photos & Videos' and finaltable.purchasetype = 'consumable'
group by category_name, purchasetype;
select count(*) from finaltable where finaltable.category_name = 'Entertainment' and finaltable.purchasetype = 'consumable'
group by category_name, purchasetype;
select count(*) from finaltable where finaltable.category_name = 'Games' and finaltable.purchasetype = 'consumable'
group by category_name, purchasetype;
select count(*) from finaltable where finaltable.category_name = 'Social Networking' and finaltable.purchasetype = 'consumable'
group by category_name, purchasetype;

--find the number of subscriptions by category
select count(*) from finaltable where finaltable.category_name = 'Utilities' and finaltable.purchasetype = 'subscription'
group by category_name, purchasetype;
select count(*) from finaltable where finaltable.category_name = 'Photos & Videos' and finaltable.purchasetype = 'subscription'
group by category_name, purchasetype;
select count(*) from finaltable where finaltable.category_name = 'Entertainment' and finaltable.purchasetype = 'subscription'
group by category_name, purchasetype;
select count(*) from finaltable where finaltable.category_name = 'Games' and finaltable.purchasetype = 'subscription'
group by category_name, purchasetype;
select count(*) from finaltable where finaltable.category_name = 'Social Networking' and finaltable.purchasetype = 'subscription'
group by category_name, purchasetype;

--find number of people for download in a given range
select count(*) from (select acct_id, count(*) from finaltable 
where finaltable.purchasetype = 'download'
group by acct_id, purchasetype
having count(*) >= 1 and count(*) <= 20) as alias;
select count(*) from (select acct_id, count(*) from finaltable 
where finaltable.purchasetype = 'download'
group by acct_id, purchasetype
having count(*) > 20 and count(*) <= 40) as alias;
select count(*) from (select acct_id, count(*) from finaltable 
where finaltable.purchasetype = 'download'
group by acct_id, purchasetype
having count(*) > 40 and count(*) <= 60) as alias;
select count(*) from (select acct_id, count(*) from finaltable 
where finaltable.purchasetype = 'download'
group by acct_id, purchasetype
having count(*) > 60 and count(*) <= 80) as alias;
select count(*) from (select acct_id, count(*) from finaltable 
where finaltable.purchasetype = 'download'
group by acct_id, purchasetype
having count(*) > 80 and count(*) <= 100) as alias;
select count(*) from (select acct_id, count(*) from finaltable 
where finaltable.purchasetype = 'download'
group by acct_id, purchasetype
having count(*) > 100) as alias;
select count(*) from (select acct_id, count(*) from finaltable 
where finaltable.purchasetype = 'download'
group by acct_id, purchasetype) as alias;

--find number of people for consumables in a given range
select count(*) from (select acct_id, count(*) from finaltable 
where finaltable.purchasetype = 'consumable'
group by acct_id, purchasetype
having count(*) >= 1 and count(*) <= 20) as alias;
select count(*) from (select acct_id, count(*) from finaltable 
where finaltable.purchasetype = 'consumable'
group by acct_id, purchasetype
having count(*) > 20 and count(*) <= 40) as alias;
select count(*) from (select acct_id, count(*) from finaltable 
where finaltable.purchasetype = 'consumable'
group by acct_id, purchasetype
having count(*) > 40 and count(*) <= 60) as alias;
select count(*) from (select acct_id, count(*) from finaltable 
where finaltable.purchasetype = 'consumable'
group by acct_id, purchasetype
having count(*) > 60 and count(*) <= 80) as alias;
select count(*) from (select acct_id, count(*) from finaltable 
where finaltable.purchasetype = 'consumable'
group by acct_id, purchasetype
having count(*) > 80 and count(*) <= 100) as alias;
select count(*) from (select acct_id, count(*) from finaltable 
where finaltable.purchasetype = 'consumable'
group by acct_id, purchasetype
having count(*) > 100) as alias;
select count(*) from (select acct_id, count(*) from finaltable 
where finaltable.purchasetype = 'consumable'
group by acct_id, purchasetype) as alias;

--find number of people for subscriptions in a given range
select count(*) from (select acct_id, count(*) from finaltable 
where finaltable.purchasetype = 'subscription'
group by acct_id, purchasetype
having count(*) >= 1 and count(*) <= 20) as alias;
select count(*) from (select acct_id, count(*) from finaltable 
where finaltable.purchasetype = 'subscription'
group by acct_id, purchasetype
having count(*) > 20 and count(*) <= 40) as alias;
select count(*) from (select acct_id, count(*) from finaltable 
where finaltable.purchasetype = 'subscription'
group by acct_id, purchasetype
having count(*) > 40 and count(*) <= 60) as alias;
select count(*) from (select acct_id, count(*) from finaltable 
where finaltable.purchasetype = 'subscription'
group by acct_id, purchasetype
having count(*) > 60 and count(*) <= 80) as alias;
select count(*) from (select acct_id, count(*) from finaltable 
where finaltable.purchasetype = 'subscription'
group by acct_id, purchasetype
having count(*) > 80 and count(*) <= 100) as alias;
select count(*) from (select acct_id, count(*) from finaltable 
where finaltable.purchasetype = 'subscription'
group by acct_id, purchasetype
having count(*) > 100) as alias;
select count(*) from (select acct_id, count(*) from finaltable 
where finaltable.purchasetype = 'subscription'
group by acct_id, purchasetype) as alias;

--find revenue by category
select sum(price) from finaltable where finaltable.category_name = 'Utilities'
group by category_name;
select sum(price) from finaltable where finaltable.category_name = 'Photos & Videos'
group by category_name;
select sum(price) from finaltable where finaltable.category_name = 'Entertainment'
group by category_name;
select sum(price) from finaltable where finaltable.category_name = 'Games'
group by category_name;
select sum(price) from finaltable where finaltable.category_name = 'Social Networking'
group by category_name;
select sum(price) from finaltable;

--find revenue by purchasetype
select sum(price) from finaltable where finaltable.purchasetype = 'download'
group by purchasetype;
select sum(price) from finaltable where finaltable.purchasetype = 'consumable'
group by purchasetype;
select sum(price) from finaltable where finaltable.purchasetype = 'subscription'
group by purchasetype;

--find the revenue of downloads by category
select sum(price) from finaltable where finaltable.category_name = 'Utilities' and finaltable.purchasetype = 'download'
group by category_name, purchasetype;
select sum(price) from finaltable where finaltable.category_name = 'Photos & Videos' and finaltable.purchasetype = 'download'
group by category_name, purchasetype;
select sum(price) from finaltable where finaltable.category_name = 'Entertainment' and finaltable.purchasetype = 'download'
group by category_name, purchasetype;
select sum(price) from finaltable where finaltable.category_name = 'Games' and finaltable.purchasetype = 'download'
group by category_name, purchasetype;
select sum(price) from finaltable where finaltable.category_name = 'Social Networking' and finaltable.purchasetype = 'download'
group by category_name, purchasetype;

--find the revenue of consumables by category
select sum(price) from finaltable where finaltable.category_name = 'Utilities' and finaltable.purchasetype = 'consumable'
group by category_name, purchasetype;
select sum(price) from finaltable where finaltable.category_name = 'Photos & Videos' and finaltable.purchasetype = 'consumable'
group by category_name, purchasetype;
select sum(price) from finaltable where finaltable.category_name = 'Entertainment' and finaltable.purchasetype = 'consumable'
group by category_name, purchasetype;
select sum(price) from finaltable where finaltable.category_name = 'Games' and finaltable.purchasetype = 'consumable'
group by category_name, purchasetype;
select sum(price) from finaltable where finaltable.category_name = 'Social Networking' and finaltable.purchasetype = 'consumable'
group by category_name, purchasetype;

--find the revenue of subscriptions by category
select sum(price) from finaltable where finaltable.category_name = 'Utilities' and finaltable.purchasetype = 'subscription'
group by category_name, purchasetype;
select sum(price) from finaltable where finaltable.category_name = 'Photos & Videos' and finaltable.purchasetype = 'subscription'
group by category_name, purchasetype;
select sum(price) from finaltable where finaltable.category_name = 'Entertainment' and finaltable.purchasetype = 'subscription'
group by category_name, purchasetype;
select sum(price) from finaltable where finaltable.category_name = 'Games' and finaltable.purchasetype = 'subscription'
group by category_name, purchasetype;
select sum(price) from finaltable where finaltable.category_name = 'Social Networking' and finaltable.purchasetype = 'subscription'
group by category_name, purchasetype;

--find the number of transaction by device
select count(*) from finaltable where finaltable.device_id = 1 
group by device_id;
select count(*) from finaltable where finaltable.device_id = 2 
group by device_id;
select count(*) from finaltable where finaltable.device_id = 3 
group by device_id;

--find the number of transaction on iPhones by category
select count(*) from finaltable where finaltable.device_id = 1 and finaltable.category_name = 'Utilities'
group by device_id, category_name;
select count(*) from finaltable where finaltable.device_id = 1 and finaltable.category_name = 'Photos & Videos'
group by device_id, category_name;
select count(*) from finaltable where finaltable.device_id = 1 and finaltable.category_name = 'Entertainment'
group by device_id, category_name;
select count(*) from finaltable where finaltable.device_id = 1 and finaltable.category_name = 'Games'
group by device_id, category_name;
select count(*) from finaltable where finaltable.device_id = 1 and finaltable.category_name = 'Social Networking'
group by device_id, category_name;

--find the number of transaction on iPads by category
select count(*) from finaltable where finaltable.device_id = 2 and finaltable.category_name = 'Utilities'
group by device_id, category_name;
select count(*) from finaltable where finaltable.device_id = 2 and finaltable.category_name = 'Photos & Videos'
group by device_id, category_name;
select count(*) from finaltable where finaltable.device_id = 2 and finaltable.category_name = 'Entertainment'
group by device_id, category_name;
select count(*) from finaltable where finaltable.device_id = 2 and finaltable.category_name = 'Games'
group by device_id, category_name;
select count(*) from finaltable where finaltable.device_id = 2 and finaltable.category_name = 'Social Networking'
group by device_id, category_name;

--find the number of downloads by device
select count(*) from finaltable where finaltable.device_id = 1 and finaltable.purchasetype = 'download'
group by device_id, purchasetype;
select count(*) from finaltable where finaltable.device_id = 2 and finaltable.purchasetype = 'download'
group by device_id, purchasetype;
select count(*) from finaltable where finaltable.device_id = 3 and finaltable.purchasetype = 'download'
group by device_id, purchasetype;

--find the number downloads available by device
select count(*) from finaltable where finaltable.device_name = 'iPhone' and finaltable.purchasetype = 'download'
group by device_name, purchasetype;
select count(*) from finaltable where finaltable.device_name = 'iPad' and finaltable.purchasetype = 'download'
group by device_name, purchasetype;
select count(*) from finaltable where finaltable.device_name = 'Both' and finaltable.purchasetype = 'download'
group by device_name, purchasetype;

--find the revenue by device
select sum(price) from finaltable where finaltable.device_id = 1
group by device_id;
select sum(price) from finaltable where finaltable.device_id = 2
group by device_id;
select sum(price) from finaltable where finaltable.device_id = 3
group by device_id;

--transaction revenue on iPhones by category
select sum(price) from finaltable where finaltable.device_id = 1 and finaltable.category_name = 'Utilities'
group by device_id, category_name;
select sum(price) from finaltable where finaltable.device_id = 1 and finaltable.category_name = 'Photos & Videos'
group by device_id, category_name;
select sum(price) from finaltable where finaltable.device_id = 1 and finaltable.category_name = 'Entertainment'
group by device_id, category_name;
select sum(price) from finaltable where finaltable.device_id = 1 and finaltable.category_name = 'Games'
group by device_id, category_name;
select sum(price) from finaltable where finaltable.device_id = 1 and finaltable.category_name = 'Social Networking'
group by device_id, category_name;

--transaction revenue on iPads by category
select sum(price) from finaltable where finaltable.device_id = 2 and finaltable.category_name = 'Utilities'
group by device_id, category_name;
select sum(price) from finaltable where finaltable.device_id = 2 and finaltable.category_name = 'Photos & Videos'
group by device_id, category_name;
select sum(price) from finaltable where finaltable.device_id = 2 and finaltable.category_name = 'Entertainment'
group by device_id, category_name;
select sum(price) from finaltable where finaltable.device_id = 2 and finaltable.category_name = 'Games'
group by device_id, category_name;
select sum(price) from finaltable where finaltable.device_id = 2 and finaltable.category_name = 'Social Networking'
group by device_id, category_name;

--create a relationship table between consumable and subscription for each person
drop table if exists purchase_table;
create table purchase_table as
(select acct_id, purchasetype from finaltable where purchasetype != 'download');
select * from purchase_table;
drop table if exists consumable_table;
create table consumable_table as
(select acct_id, count(purchasetype='consumable') as consumable_counts from purchase_table
group by acct_id, purchasetype);
select * from consumable_table;
drop table if exists subscription_table;
create table subscription_table as
(select acct_id, count(purchasetype='subscription') as subscription_counts from purchase_table
group by acct_id, purchasetype);
select * from subscription_table;
drop table if exists purchase_relation_table;
create table purchase_relation_table as
(select consumable_table.*, subscription_table.subscription_counts from consumable_table
left join subscription_table on consumable_table.acct_id = subscription_table.acct_id);
select * from purchase_relation_table;

