#8weeks-02----- A PART
/* 此题数据库可用于查询多个指标，可以分以下几个方面：
Pizza Metrics  披萨指标
Runner and Customer Experience   外卖骑手和客户体验
Ingredient Optimisation  成分优化
Pricing and Ratings  定价和评级
Bonus DML Challenges (DML = Data Manipulation Language)  DML 挑战奖励（DML = 数据操作语言） 
*/

## 第一个方面 Pizza Metrics  披萨指标
/*1.订购了多少个披萨？
 USE pizza_runner;
 
 SELECT COUNT(*) AS total_pizza_num
 FROM customer_orders;

 
# 2.发出了多少个独特的客户订单？How many unique customer orders were made?
SELECT COUNT(DISTINCT(customer_id)) AS uni_customer
FROM customer_orders
 
 #3.每位骑手成功交付了多少订单？How many successful orders were delivered by each runner?
SELECT runner_id,  COUNT(*) AS runner_num
FROM runner_orders r
WHERE pickup_time !='null'
GROUP BY runner_id
ORDER BY runner_id;

#4.每种类型的披萨交付了多少个？How many of each type of pizza was delivered?
SELECT pizza_id, COUNT(*) AS each_pizza_num
FROM customer_orders
GROUP BY pizza_id;

# 5.每个顾客点了多少两种pizza？How many Vegetarian and Meatlovers were ordered by each customer?
#exclusions是应从披萨中删除的ingredient_id值， extras项是需要添加到披萨中的ingredient_id值。
SELECT customer_id, p.pizza_name,
	COUNT(c.pizza_id) AS typeofpizza_num  #因为分组过了，所以这里直接COUNT就好
FROM customer_orders c
LEFT JOIN pizza_names p
	ON c.pizza_id = p.pizza_id
GROUP BY customer_id, p.pizza_name
ORDER BY c.customer_id;

推荐!!!：
SELECT customer_id,  #由行转换成了列title,定义了列名 
       SUM(CASE WHEN pizza_id = 1 THEN 1 ELSE 0 END) AS 'Meat lover Pizza Count', 
       SUM(CASE WHEN pizza_id = 2 THEN 1 ELSE 0 END) AS 'Vegetarian Pizza Count'
FROM customer_orders_temp
GROUP BY customer_id
ORDER BY customer_id;

#6. 单笔订单最多配送多少个披萨？What was the maximum number of pizzas delivered in a single order?
# 提到最多极限值就要想起 ORDER BY...和LIMIT...组合！！不要只想着MAX！
SELECT customer_id, order_id, COUNT(*) AS max_pizzanum_per
FROM customer_orders
GROUP BY customer_id, order_id
ORDER BY COUNT(*) DESC
LIMIT 1;

SELECT MAX(b) AS maxi_num_per_order
FROM(
SELECT order_id, COUNT(*) AS b
FROM customer_orders
GROUP BY order_id
) AS P1

# 7. 对于每位顾客，有多少份外送披萨至少有 1 次更改，有多少份没有更改？

##由于customer_orders表与runner_orders表中空格和nulll的数据表现格式混乱，我们为了下面的计算方便，
对这两个表分别做一下数据清理；
1.创建一个包含所有列的临时表(不要用临时表！！！电脑会崩溃！）
2.删除排除exlusions和extras列中的空值并用空格“ ”替换。
----我是直接DROP了旧表,然后重新导入了创建新表,修改了数据源! 

#除了customer_orders表里的披萨更改，前提是必须是送出去的，所以还要排除runner_orders中被取消的数据
SELECT customer_id,  
	SUM(CASE WHEN exclusions != '' OR extras != '' THEN 1 ELSE 0 END) AS atleastonechange,
    SUM(CASE WHEN exclusions = '' AND extras = '' THEN 1 ELSE 0 END) AS nochange
FROM customer_orders c
JOIN runner_orders r   
	ON c.order_id = r.order_id   
WHERE r.cancellation = ''
GROUP BY customer_id;

#8. 有多少份已配送的披萨同时包含exclusions 和extras ？
SELECT c.order_id, c.customer_id, c.pizza_id  #COUNT(*) AS cus_withexcluandextra
FROM customer_orders c
JOIN runner_orders r   
	ON c.order_id = r.order_id
WHERE c.exclusions != '' AND c.extras != '' AND r.cancellation = '';

#9. 一天中每小时订购的披萨总量是多少？ What was the total volume of pizzas ordered for each hour of the day?
#这段代码的主要功能是统计一天中每个小时的订单数
SELECT 
  HOUR(order_time) AS hour_of_day,
  COUNT(order_id) AS pizza_count
FROM customer_orders
GROUP BY HOUR(order_time)
ORDER BY hour_of_day;
*/

# 10. 一周中每一天的订单量是多少？What was the volume of orders for each day of the week?
# ！意为以一周为单位，看星期几订单量最高？ 所以要按照每个星期几来分组！

/*DATE_FORMAT 更灵活，可以指定其他日期或时间部分的格式。
   DAYNAME 函数更直接，专用于提取星期几名称。*/
/*
SELECT 
  DAYNAME(DATE_ADD(order_time, INTERVAL 2 DAY)) AS day_of_week, #加两天让一周的开始是星期一，因为国外软件默认星期天是一周开始 
  COUNT(order_id) AS total_pizzas_ordered
FROM customer_orders
GROUP BY DAYNAME(DATE_ADD(order_time, INTERVAL 2 DAY))
ORDER BY total_pizzas_ordered DESC;
*/








