#8weeks-02----- B PART 外卖骑手和客户体验
/* 此题数据库可用于查询多个指标，可以分以下几个方面：
Pizza Metrics  披萨指标
Runner and Customer Experience   外卖骑手和客户体验
Ingredient Optimisation  成分优化
Pricing and Ratings  定价和评级
Bonus DML Challenges (DML = Data Manipulation Language)  DML 挑战奖励（DML = 数据操作语言） 
*/

## 第二个方面 Runner and Customer Experience   外卖骑手和客户体验
/*
#1.每 1 周有多少骑手注册？（即周从2021-01-01开始）How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
SELECT WEEK(registration_date, 1) AS registration_weeks, COUNT(*) AS amoutof_runner_regi
FROM runners
GROUP BY registration_weeks;   

(关键在于题目想要的每一周呈现效果是怎样的？(可应用到今年的第一周销量更好）
MySQL 的 WEEK() 函数通常按周日或周一作为一周的起始日来计算，
但是你明确要求从 2021年1月1日（周五）开始，所以你需要在查询中处理这个自定义的周起始日期

SELECT 
  #STR_TO_DATE(CONCAT('2021-01-01'), '%Y-%m-%d') + INTERVAL (FLOOR(DATEDIFF(registration_date, '2021-01-01') / 7) * 7) DAY AS week_start_date,
  CONCAT('第', FLOOR(DATEDIFF(registration_date, '2021-01-01') / 7) + 1, '周') AS week_number,
  COUNT(*) AS amount_of_runner_regi
FROM runners
GROUP BY week_number
ORDER BY week_number;

/*解释：FLOOR(DATEDIFF(registration_date, '2021-01-01') / 7) + 1
DATEDIFF(registration_date, '2021-01-01')：计算注册日期与 2021年1月1日 之间的天数。
FLOOR(DATEDIFF(...) / 7)：通过将天数除以 7，计算出注册日期属于哪个周，并取整;
+ 1：确保周数从 1 开始。*/
/*
# 2.每位骑手到达 Pizza Runner 总部取货的平均时间是多少分钟？(涉及下单时间c和取货时间r）
# DATEDIFF函数只能算两个日期之间的间隔天数，而不能返回分钟小时等；应使用TIMESTAMPDIFF函数
SELECT runner_id, 
	ROUND(AVG(TIMESTAMPDIFF(MINUTE, c.order_time, r.pickup_time)), 1) AS avg_pickup_time
FROM runner_orders r
JOIN customer_orders c
	ON r.order_id = c.order_id
WHERE cancellation = '' 
GROUP BY runner_id;
*/
# 3. 披萨的数量和订单准备时间之间有什么关系吗？
/*分析：订单准备时间实则就是 下单时间c.order_time 到 取货时间r.pickup_time 之间的差值，
每个订单包含的pizza数量需要从c表以订单ID分组 + COUNT得出

这里AVG并没有以每个订单内所有pizza的数量为分母，为什么？
------有，但是因为每个订单内的所有pizza它的下单时间和取单时间内部都是相同的，因此，无论如何计算，
    所有披萨的准备时间相加之后，除以披萨数量，最终的平均准备时间还是相同的。*/
/*
WITH PizzaPrep AS (
	SELECT 
		c.order_id,
		COUNT(*) AS pizza_num, 
		ROUND(AVG(TIMESTAMPDIFF(MINUTE, c.order_time, r.pickup_time)), 1) AS order_prep_time
		#这里的AVG与上一题不同的是分母不同，这里的分母是每个订单内所有pizza的数量；上面的AVG分母是是每个骑手所送订单的数量；
	FROM customer_orders c
	JOIN runner_orders r 
		ON c.order_id = r.order_id
	WHERE cancellation = '' 
	GROUP BY c.order_id
)

SELECT pizza_num, 
	ROUND(SUM(order_prep_time)/SUM(pizza_num),1) AS each_prep_time
FROM PizzaPrep
GROUP BY pizza_num; */
/*注意这里使用两个SUM相除，而不是AVG，因为是按pizza_num分组，它的分组就会是每个订单内pizza数量的个数，
分母就变成了每个特定pizza数量的个数，而不是pizza的数量本身了*/

/*
#4.每个顾客的平均配送距离是多少？
# 先在数据源头调整对齐一下数据格式 
SELECT c.customer_id, 
	ROUND(AVG(r.distance_km), 1) AS avg_distance
FROM customer_orders c
JOIN runner_orders r
	ON c.order_id = r.order_id
WHERE cancellation = ''
GROUP BY c.customer_id;

# 5.所有订单的最长和最短交货时间有什么区别？What was the difference between the longest and shortest delivery times for all orders?
SELECT order_id, duration_mins
FROM runner_orders
WHERE cancellation = '';

# 6. 每个骑手送每个订单的平均速度是多少？您是否注意到这些值有任何趋势？
#答：骑手1的每个订单平均速度从37.5km/h到60km/h；骑手2的订单平均速度从35.1km/h到93.6km/h；
#    骑手3的订单平均速度从40 km/h ；其中有注意到骑手2订单8号的平均速度高达93.8km/h，表现异常，应调查关注。
# 分析：应把路程分钟换成小时；
SELECT runner_id, order_id, pickup_time,
	ROUND((distance_km/(duration_mins/60)),1) AS per_order_avg_speed
FROM runner_orders
WHERE cancellation = ''
ORDER BY runner_id;
*/
# 7.每个骑手的成功交付百分比是多少？ What is the successful delivery percentage for each runner?
#答：骑手 1 的交付成功率为 100%；骑手 1 的交付成功率为 100%；骑手 3 的成功交付率为 50%；但把所有订单取消的原因都归为骑手从而影响交付率是不合理的。
SELECT runner_id,
	CONCAT(FORMAT(SUM(IF(pickup_time !='null', 1, 0))/COUNT(*) * 100, 0) , '%') AS suc_deliv_percent
FROM runner_orders
GROUP BY runner_id;
