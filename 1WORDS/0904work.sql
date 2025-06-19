## HAVING子句--1. WHERE语句可以在分组之前筛选数据，HAVING语句则是在分组后筛选数据
#如果只想要包含总销售200美金以上的客户怎么办？
/*SELECT
	client_id,
	SUM(invoice_total) AS total_sales
FROM invoices
-- WHERE total_sales > 500    
#在这里不能用WHERE语句的原因：语句运行到这的时候还未分组goup by
#在这我们还不知道每个顾客id的total_sales
GROUP BY client_id
HAVING total_sales > 500

# 如果这还想加一个超过5张发票的限制条件
# 2. HAVING子句后的条件必须是SELECT语句中有的，比如total_sales
#    WHERE语句后的条件，不论是SELECT后有没有的条件都可以
SELECT
	client_id,
	SUM(invoice_total) AS total_sales,
    COUNT(*) AS number_of_invoices    # 每组（client_id)的发票数
FROM invoices
GROUP BY client_id
HAVING total_sales > 500 AND number_of_invoices > 5
*/

# 练习：筛选出地址在Virginia 并且花费超过100美元的顾客(需自己再练习一遍)
# 拆解：1. 先筛选出位于Virginia的顾客，
#       2. 然后连接customers表和orders表以customer_id为条件；
#       3. 最后连接orders表和order_items表，以order_id为条件
/*
USE sql_store;

SELECT 
	c.customer_id,  #理清是根据顾客id分组的逻辑
    c.first_name,
    c.last_name,
    SUM(oi.quantity * oi.unit_price) AS total_sales
FROM customers c
JOIN orders o 
	USING (customer_id)
JOIN order_items oi
	USING (order_id)
WHERE state = 'VA'  #WHERE语句用在分组前
GROUP BY 
	c.customer_id,
    c.first_name,
    c.last_name
#当你的SELECT语句中有聚合函数且对数据分组GROUP BY语句时，应该根据select子句中的所有列进行分组
HAVING total_sales > 100   #HAVING语句用在分组后
*/


##WITH ROLLUP运算符——汇总数据,只能应用聚合值的列！
# rollup语句不是一个标准的sql语言，所以无法在sql或Oracle中执行这个查询
#为每个客户计算总销售
/*
USE sql_invoicing;
SELECT
	client_id,
    SUM(invoice_total) AS total_sales
FROM invoices i
GROUP BY client_id WITH ROLLUP
*/

#如果使用多列分组,ROLLUP函数会对每一组都进行汇总计算,以及整个结果集的汇总值
/*
USE sql_invoicing;
SELECT
	state,
    city,
    SUM(invoice_total) AS total_sales
FROM invoices i
JOIN clients c USING (client_id)
GROUP BY state, city WITH ROLLUP
*/

# 练习：查询返回这样一个结果：根据支付方式的汇总，包括两列payment_method和total 以及最后的汇总
/*
SELECT 
	pm.name AS payment_method,
    SUM(amount) AS total
FROM payments P 
JOIN payment_methods pm
	ON (p.payment_method = pm.payment_method_id)
GROUP BY pm.name WITH ROLLUP 
# 我们在使用rollup运算符时，不能在GROUP BY子句中使用列别名，这我们不能使用payment_method
*/


