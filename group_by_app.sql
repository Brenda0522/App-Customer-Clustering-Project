select t1.app_id, t1.content_count, t2.account_count, t3.download_count, t4.subscription_count, t5.consumable_count, t6.iphone_count, t7.ipad_count, t8.total_revenue from 

(
select app_id, count(distinct content_id) as "content_count"
from finaltable
group by app_id
) as t1

left join

(
select app_id, count(distinct acct_id) as "account_count"
from finaltable
group by app_id
) as t2

on t1.app_id = t2.app_id

left join

(
select app_id, count (*) as "download_count"
from finaltable
where purchasetype = 'download'
group by app_id
) as t3

on t1.app_id = t3.app_id

left join

(
select app_id, count (*) as "subscription_count"
from finaltable
where purchasetype = 'subscription'
group by app_id
) as t4

on t1.app_id = t4.app_id

left join

(
select app_id, count (*) as "consumable_count"
from finaltable
where purchasetype = 'consumable'
group by app_id
) as t5

on t1.app_id = t5.app_id

left join

(
select app_id, count (*) as "iphone_count"
from finaltable
where device_id = 1
group by app_id
) as t6

on t1.app_id = t6.app_id

left join

(
select app_id, count (*) as "ipad_count"
from finaltable
where device_id = 2
group by app_id
) as t7

on t1.app_id = t7.app_id

left join

(
select app_id, SUM(price) as "total_revenue"
from finaltable
group by app_id
) as t8

on t1.app_id = t8.app_id