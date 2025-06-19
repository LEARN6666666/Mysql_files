## SELF OUT JOIN 
/*USE sql_hr;

SELECT 
	e.employee_id,     #这里由于是一个表自身不同列的对应结合，
    e.first_name,      #所以也需加上以不同列为准的“表”的缩写标示
    m.first_name AS manager		
FROM employees e   #自定缩写
LEFT JOIN employees m  #表中对应的经理列reports_to
	ON e.reports_to = m.employee_id 
#这个结果缺少一条37270id本人的manager数据，所以可用LEFT JOIN返回e表的所有数据  */


## USING 语句
#USING 语句用的条件是必须在两个表中对应列的名字是相同的
# 如果ON 条件两表的对应列名字相同，我们可以使用更简便的USING语句
/*USE sql_store;

SELECT
	o.order_id,
    c.first_name,
    sh.name AS shipper
FROM orders o
JOIN customers c
	-- ON o.customer_id = c.customer_id
# ON语句复杂难阅读，可简化。
	USING (customer_id)
LEFT JOIN shippers sh
	USING (shipper_id)        */
    
#order_items表中是复合主键，所以这两列的组合是唯一标识这个表每条数据 的条件
# 将order_items表与order_item_notes表利用复合主键连接，并用USING简化
/*SELECT 
	*
FROM order_items oi
JOIN order_item_notes oin
	USING (order_id, product_id)         */
# 两个条件用逗号，相连

#练习:返回sql_invoicing数据库，有date, client, amount,name(支付方式名字）数据列
/*USE sql_invoicing;

SELECT 
	p.date,
    p.amount AS client,
    c.name,
    pm.name AS payment_method
FROM payments p
JOIN clients c 
	USING (client_id)  #注意是英文状态下的括号！！
JOIN payment_methods pm
	ON p.payment_method = pm.payment_method_id            */


## Natural JOINS 自然连接，更容易将两个表结合起来的方式,但比较容易出现意外，不推荐
/*SELECT 
	o.order_id,
    c.first_name
FROM orders o, 
NATURAL JOIN customers c
#数据库引擎会查询这两个表，并将它们基于公共列连接      */


## CROSS JOIN 交叉连接,会将A表的每条记录与B表中每条记录连接
#crossjoin用于有大小表的地方，比如一个表有小中大，另一个表有各种颜色,想要所有大小和颜色的组合时可用
/*SELECT 
	c.first_name AS customer,
    p.name AS product
FROM customers c
CROSS JOIN products p  #显性语法
ORDER BY c.first_name         
#每个顾客都有所有产品的展示，没有用cross join的意义
#隐性语法
SELECT 
	c.first_name AS customer,
    p.name AS product
FROM customers c, products p
ORDER BY c.first_name      */

#练习：分别用显性语法和隐性语法 交叉连接shippers表和 products表
/*SELECT 
	p.product_id,
    sh.name AS address
FROM shippers sh 
CROSS JOIN products p
ORDER BY p.product_id 

SELECT 
	p.product_id,
    sh.name AS address
FROM shippers sh, products p
ORDER BY p.product_id           */


## UNION 将行与多个表组合
# 如果我们要将orders表中的日期，当年的就做active状态标记，过去的就作为档案
 #这个例子两个查询都在一张表中;
/*SELECT 
	order_id,
    order_date,
    'Active' AS status
FROM orders
WHERE order_date >= '2019-01-01'          
UNION   
SELECT 
	order_id,
    order_date,
    'Archived' AS status
FROM orders
WHERE order_date <= '2019-01-01'             */

# 也可针对不同表格查询将结果合并在一张表中
#两个查询SELECT 列数 需相等
/*SELECT first_name  #第一个SELECT语句确定结合列的名称
FROM customers 
UNION
SELECT name
FROM shippers  #把顾客表中所有firstname行和shippers表中所有name行结合           */   
		
# 练习:查询四列customer_id, first_name, points, type(没有表中有这列,需我们自己定义根据积分
#type(p<2000-Bronze; p[2000,3000]-Sliver; p>3000-Gold)
/*SELECT 
	customer_id,
    first_name,
    points,
    'Bronze' AS type
FROM customers
WHERE points < 2000
UNION
SELECT 
	customer_id,
    first_name,
    points,
    'Sliver' AS type
FROM customers
-- WHERE  points <= 3000 AND points >= 2000
WHERE points BETWEEN 2000 AND 3000
UNION
SELECT 
	customer_id,
    first_name,
    points,
    'Glod' AS type
FROM customers
WHERE points > 3000
ORDER BY first_name              */  


