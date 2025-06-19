## 聚合函数——取系列值并聚合它们，导出一个单一值,只运行非空值！！注意NULL值
# COUNT(*)计算返回所有项，不管有没有NULL值
# MAX() . MIN(). AVG(). SUM() . 
/*SELECT 
	MAX(invoice_total) AS highest,
    -- MAX(payment_date) AS highest,      #也可用于日期和字符串
    MIN(invoice_total) AS lowest,
    AVG(invoice_total) AS average,
    SUM(invoice_total) AS total,
    COUNT(invoice_total) AS number_of_invoices,
    COUNT(payment_date) AS count_of_payments,  # 由于发票日期这列允许空值，所以只返回计算了非空值
    COUNT(*) AS total_records  
FROM invoices        

# 函数也可作用于表达式
# 如果不想计算进重复项，记得用DISTINCT
SELECT 
	MAX(invoice_total) AS highest,
    MIN(invoice_total) AS lowest,
    AVG(invoice_total) AS average,
    SUM(invoice_total * 1.1) AS total, #运行逻辑是先返回invoice_total列的值，然后各值*1.1，最后求和
    -- COUNT(invoice_total) AS total_records  
    -- COUNT(client_id) AS total_records  #count的逻辑是直接返回有client_id的记录数，不管其中是不是有重复项
	COUNT(DISTINCT client_id) AS total_records  #有三个唯一的客户拥有2019.7.1后的发票，不管他有几张
FROM invoices
WHERE invoice_date > '2019-07-01'
*/

# 练习：编写一个查询来得到一个4*3的表
# 四列：date_range, total_sales, total_payments, what_we_expect(即前两列差值）
# 三行： First half of 2019, Second half of 2019, Total

/*SELECT 
	'First half of 2019' AS date_range,
	SUM(invoice_total) AS total_sales,
    SUM(payment_total) AS total_payments,
    SUM(invoice_total - payment_total) AS 'what_we_expect'
FROM invoices
WHERE invoice_date BETWEEN '2019-01-01' AND '2019-6-30'  
UNION
SELECT 
	'Second half of 2019' AS date_range,   #注意 AS 前是这一项的返回值！！如果是字符串的话
	SUM(invoice_total) AS total_sales,
    SUM(payment_total) AS total_payments,
    SUM(invoice_total - payment_total) AS 'what_we_expect'
FROM invoices
WHERE invoice_date > '2019-6-30' 
UNION   #需要三行一行一行的连接起来
SELECT 
	'Total' AS date_range,
	SUM(invoice_total) AS total_sales,
    SUM(payment_total) AS total_payments,
    SUM(invoice_total - payment_total) AS 'what_we_expect'
FROM invoices
WHERE invoice_date BETWEEN '2019-01-01' AND '2019-12-31'
*/

## GROUP BY语句
#如果要知道每个客户的总销售是多少，就需要分组计算（因为客户id有重复的
## 注意这些子句的顺序！SELECT——FROM——WHERE——GROUP BY——ORDER BY
/*SELECT
	client_id,
	SUM(invoice_total) AS total_sales
FROM invoices
WHERE invoice_date >= '2019-07-01'   # 想要计算每个客户的总销售额，但是仅限下半年
GROUP BY client_id  # group by 语句一定是在order by语句之前和WHERE语句之后
ORDER BY total_sales DESC  #以总销售额降序排列
*/


## 如何使用多列分组
# 首先连接invoices表和clients表,想要以州state和城市city分组计算数据
/*SELECT
	state,
    city,
	SUM(invoice_total) AS total_sales
FROM invoices
JOIN clients USING (client_id) 
GROUP BY state, city 
ORDER BY total_sales DESC
# 我们看到的表是根据每个州和城市对应组合的总销售量，虽然这里的数据集内一个州内只对应着一个城市
*/

#练习：查询返回三列，分别为date, payment_method, total_payments,以日期和付款方式对应分组
# 拆分为先按照日期分组的total_payment，然后与有付款方式的pm表连接，返回pm.name
/*SELECT 
	date,
    pm.name AS payment_method,
    SUM(amount) AS total_payments
FROM payments p
JOIN payment_methods pm 
	ON p.payment_method = pm.payment_method_id  #注意条件列名对应
GROUP BY date, payment_method
ORDER BY date
*/
