#8weeks-02----- C PART Ingredient Optimisation  成分优化
/* 此题数据库可用于查询多个指标，可以分以下几个方面：
Pizza Metrics  披萨指标
Runner and Customer Experience   外卖骑手和客户体验
Ingredient Optimisation  成分优化
Pricing and Ratings  定价和评级
Bonus DML Challenges (DML = Data Manipulation Language)  DML 挑战奖励（DML = 数据操作语言） 
*/

# 1. 每个披萨的标准成分是什么？What are the standard ingredients for each pizza?
/*分析：关键在于单元格数据的拆分----SUBSTRING_INDEX函数 ；拆分后创建个新表，对新表再查询
SUBSTRING_INDEX([列名], (单元格内相应的分隔符), count)
count：
正数：从左往右，取从起始到第count个分隔符之间的内容。
负数：从右往左，取从起始到第count个分隔符之间的内容。-1其实就是最后一个数

number.n 这里指的是创建新的数字表内的序号，使用numbers.n逐行控制提取第几个数字
numbers表提供数字序列（n），用于控制提取toppings列中第n个逗号分隔的内容；

TRIM(...)用于去除结果字符串中的前后空格。

CHAR_LENGTH(toppings): toppings 字符串的总长度。
CHAR_LENGTH(REPLACE(toppings, ',', '')): 移除所有 , 之后的字符串长度。
两者相减后，得到 , 的数量，再加 1，就得到了 toppings 里实际的项数。


#由于Mysql没有内置SPLIT函数，所以用兼容性更高的(SUBSTING_INDEX + JOIN numbers)的方法，以下为第一种：
WITH split_toppings AS (
SELECT pizza_id,
	TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(toppings, ',', numbers.n), ',', -1)) AS topping_num
FROM pizza_recipes
JOIN (  #JOIN 让 numbers.n 取值 1,2,3,...，直到 toppings 里的最大项数，实现字符串拆分成多行。
    SELECT 1 AS n UNION ALL 
    SELECT 2 UNION ALL 
    SELECT 3 UNION ALL 
    SELECT 4 UNION ALL 
    SELECT 5 UNION ALL 
    SELECT 6 UNION ALL 
    SELECT 7 UNION ALL 
    SELECT 8 UNION ALL 
    SELECT 9 UNION ALL 
    SELECT 10 UNION ALL 
    SELECT 11 UNION ALL 
    SELECT 12
)numbers
   ON CHAR_LENGTH(toppings) - CHAR_LENGTH(REPLACE(toppings, ',', '')) + 1 >= numbers.n
	# 大于号左边部分：实为一行中我们需要的part总数 ,这里一号pizza的配料有八个数，那numbers表就应该取1，2,3,4,5,6,7,8；
)
*/
/*  第二种：MySQL 8.0+以后的版本，可以借助 JSON 函数 来实现 SPLIT() 的效果：
实为把行中的项转为数组，然后再用JSON_TABLE函数解析数组，
JSON_TABLE(..., "$[*]")每个元素单独拆成行；
COLUMNS (topping_num INT PATH "$") 定义一个拆成列 topping_num，并指定它的数据类型和路径;
"$" 代表 JSON 解析路径，指向 JSON 数组中的每个元素。
在 JSON_TABLE() 解析时，它会遍历 JSON 数组，每个元素作为 topping_num 取出。
*/
WITH split_toppings AS(
SELECT pizza_id, topping_num
FROM pizza_recipes,
JSON_TABLE(
    CONCAT('["', REPLACE(toppings, ',', '","'), '"]'), 
    "$[*]" COLUMNS (topping_num INT PATH "$")
) AS split_result
WHERE topping_num IS NOT NULL AND topping_num != ''
)
SELECT s.pizza_id, s.topping_num, p.topping_name
FROM split_toppings s
LEFT JOIN pizza_toppings p
	ON s.topping_num = p.topping_id
ORDER BY s.pizza_id, s.topping_num;

#2.最常添加的额外内容是什么？ What was the most commonly added extra?
# 当CTE表达式内包含聚合时GROUP BY或count等，是在内部聚合的；
# MySQL中，不能直接执行CTE语句，因为CTE是一个临时结果集，通常需要和 SELECT/INSERT/UPDATE/DELETE语句一起使用。

WITH extra_count_cte AS(
SELECT extras_num, COUNT(*) AS extra_count
FROM customer_orders,
JSON_TABLE(
    CONCAT('["', REPLACE(extras, ',', '","'), '"]'), 
    "$[*]" COLUMNS (extras_num INT PATH "$")
) AS split_result
WHERE extras_num IS NOT NULL AND extras_num!= ''
GROUP BY extras_num
)
SELECT e.extras_num, p.topping_name AS like_extra
FROM extra_count_cte e
LEFT JOIN pizza_toppings p
	ON e.extras_num = p.topping_id
ORDER BY e.extra_count DESC
LIMIT 1;


#3.最常见的排除是什么？What was the most common exclusion?
WITH exclu_count_cte AS(
SELECT exclu_num, COUNT(*) AS exclu_count
FROM customer_orders,
JSON_TABLE(
    CONCAT('["', REPLACE(exclusions, ',', '","'), '"]'), 
    "$[*]" COLUMNS (exclu_num INT PATH "$")
) AS split_result
WHERE exclu_num IS NOT NULL AND exclu_num!= ''
GROUP BY exclu_num
)
SELECT e.exclu_num, p.topping_name AS like_extra
FROM exclu_count_cte e
LEFT JOIN pizza_toppings p
	ON e.exclu_num = p.topping_id
ORDER BY e.exclu_count DESC
LIMIT 1;


/*Generate an order item for each record in the customers_orders table in the format of one of the following:
4.为customers_orders表中的每条记录生成一个订单项目，格式如下之一：
Meat Lovers
Meat Lovers - Exclude Beef
Meat Lovers - Extra Bacon
Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
*/




/*


Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
5.从customer_orders表中为每个披萨订单生成按字母顺序排列的逗号分隔成分列表，并在任何相关成分前面添加2x
For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"  例如： "Meat Lovers: 2xBacon, Beef, ... , Salami"

What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
6.按最常见的顺序排列的所有交付的比萨饼中使用的每种成分的总量是多少？
*/
