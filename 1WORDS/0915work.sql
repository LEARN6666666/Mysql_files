## SELECT语句中的子查询
# 想生成有invoice_id, invoice_total, invoice_average, difference(前两列的差）列的数据表
# !!!由于表达式中不能使用列的别名，所以可将查询中的列转化成一段子查询
/*SELECT
	invoice_id,
    invoice_total,
    (SELECT AVG(invoice_total)
		FROM invoices) AS invoice_average,
	invoice_total - (SELECT invoice_average) AS difference
	#'invoice_total - invoice_average' AS differece # 表达式中不能使用列的别名invoice_average
    # 也可将上一行子查询带入这一行invoice_total- (SELECT...),但太长了且语句重复查询
FROM invoices
*/
#练习：筛选出client_id, name, total_sales(每个顾客id的发票总计）, average(所有发票总记的平均），difference
#自己的尝试：
/*SELECT 
	DISTINCT (client_id), #FROM clients了为什么还要DISTINCT
    (SELECT name 
		FROM clients
        LEFT JOIN invoices USING (client_id)) AS name
    (SELECT SUM (invoice_total)
	    FROM invoices
        GROUP BY client_id) AS total_sales,
	AVG (invoice_total) AS average,
    (SELECT total sales) - (SELECT average) AS difference
FROM  clients
*/
#老师的答案：以clients表为主表，省了连接的事儿
/*SELECT
	client_id,
    name,
    (SELECT SUM(invoice_total)
		FROM invoices
        WHERE client_id = c.client_id) AS total_sales,
	(SELECT AVG(invoice_total) FROM invoices) AS average,
    (SELECT total_sales - average) AS difference  #转化子查询
FROM clients c
*/

# FROM里面的子查询:每当我们在from里使用子查询时，必须基于一个别名，不管会不会用到！
# 上个练习中的例子结果表，有用，想把它当做一个真实表，如何保存使用
# 由于在FROM语句后使用这么长的子查询过于复杂，可以使用视图VIEW，将这段查询作为视图存储在数据库中，可大大简化
/*SELECT *
FROM (
	SELECT
	client_id,
    name,
    (SELECT SUM(invoice_total)
		FROM invoices
        WHERE client_id = c.client_id) AS total_sales,
	(SELECT AVG(invoice_total) FROM invoices) AS average,
    (SELECT total_sales - average) AS difference  #转化子查询
FROM clients c
) AS sales_summary
# 想要返回有发票的顾客项目，加个WHERE语句
WHERE total_sales IS NOT NULL
#还可将这张表与其他表联接等等
*/

