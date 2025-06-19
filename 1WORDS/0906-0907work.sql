##编写复杂查询--下面的课程是编写一系列子查询
# 首先重新恢复数据集初始状态，课程原因为了确保两方数据集相同，只要打开数据集的sql文件然后执行就好
# 1.编写一段简单的子查询开启本节——找到比产品id为3的更贵的产品
#     ——子查询：返回一个单一值
/*SELECT *
FROM products
-- WHERE unit_price > 3.35
WHERE unit_price > (
	SELECT unit_price
    FROM products
    WHERE product_id = 3
)  #在括号中填写子查询
# 执行逻辑是先执行子查询，然后将子查询的结果返回给外查询


# 练习：在sql_hr的数据库内，查询出所有收入在平均线以上的雇员employees
USE sql_hr;

SELECT 
	employee_id,
    first_name,
    last_name,
    salary
FROM employees
WHERE salary > (
	SELECT AVG(salary)
    FROM employees
)
*/

# P47 IN运算符---怎么用IN运算符写子查询
# 假设你想查询没有被订购过的产品: 子查询：返回一个列表的值
# 1. 首先查询出所有订购过的产品id在order_items表
# 2. 之后再返回不在这其中的product_id 
/*USE sql_store;
SELECT *
FROM products
WHERE product_id NOT IN (
	SELECT DISTINCT(product_id)
	FROM order_items
)
*/

#练习：查询找到没有发票invoices的客户
/*USE sql_invoicing;

SELECT *
FROM clients
WHERE client_id NOT IN ( 
	SELECT DISTINCT(client_id)
	FROM invoices
)
*/

## 子查询 VS 联接JOIN——由具体例子的1可读性 和 2表现
# 用上面这个发票的例子，但改用联接方式，先连接两个表,再用WHERE条件筛选连接后表中的对应条件
/*SELECT *
FROM clients c
LEFT JOIN invoices i   #left join 不管顾客有没有发票都能获取所有客户
	-- ON c.client_id = i.client_id
    USING (client_id)
WHERE invoice_id IS NULL
*/
# 练习：查询哪些顾客订购过生菜lettuce产品id=3,用两种方法子查询和联接
/*USE sql_store;
# 1. 联接法 JOIN
/*SELECT 
	DISTINCT(c.customer_id),
    c.first_name,
    c.last_name
FROM order_items oi
JOIN orders o USING (order_id)
JOIN customers c USING (customer_id)
WHERE oi.product_id = 3
ORDER BY c.customer_id    */

# 1. 联接法（MOSH给的解答，他认为的最佳
/*SELECT 
	DISTINCT(c.customer_id),
    c.first_name,
    c.last_name
FROM customers c 
JOIN orders o USING (customer_id)
JOIN order_items oi USING (order_id)
WHERE oi.product_id = 3       */

# 2. 子查询（自己的答案）
# 为什么子查询SELECT里可以不用DISTINCT去除重复项?
#  !!因为IN运算符会隐式去掉重复值!!
/*SELECT 
	customer_id,
    first_name,
    last_name
FROM customers 
WHERE customer_id IN (
		SELECT customer_id
        FROM orders
        WHERE order_id IN (
			SELECT order_id
            FROM order_items
            WHERE product_id = 3
        )
)
ORDER BY customer_id DESC     */

# 子查询：MOSH老师的答案，结合使用了子查询和联接
/*SELECT 
	customer_id,  #为什么这里可以不用DISTINCT?
    first_name,
    last_name
FROM customers c
WHERE customer_id IN (
	SELECT o.customer_id
    FROM order_items 
    JOIN orders o USING (order_id) #因为对应列是orders表内的主键列，唯一，则可用内连接
    WHERE product_id = 3
)     */

## ALL关键词——MAX和ALL两个语句可以互相改写
# 选择所有比顾客3拥有的所有发票金额值要大的发票
#第一种方法：运用了聚合函数MAX —— 子查询返回了一个单一值!
# 1. 先查询出顾客id为3的所有发票值
# 2. 将1段作为子查询，用于选择所有总额大于（顾客3最大的发票值）
/*USE sql_invoicing;
SELECT *
FROM invoices
WHERE invoice_total > (
	SELECT MAX(invoice_total)
	FROM invoices
	WHERE client_id = 3
)      */

#第二种方法：应用ALL关键词 —— 子查询返回了一列值！
#这段子查询中返回的是顾客3所有的发票值，显化出来就是
# WHERE invoice_total > ALL (150， 130, 167， ...)
# 3. 然后mysql就会查看invoices表，对于表中每行都会把发票总额和这些括号内的数据比较，
# 如果其中一行的invoice_total大于括号内所有ALL的这些值，那么那行就会返回到最终结果集。
/*SELECT *
FROM invoices
WHERE invoice_total > ALL (
	SELECT invoice_total
	FROM invoices
	WHERE client_id = 3
)    */


## ANY关键词 ---如果这个顾客id等于子查询中返回值里的任意一个，则那个顾客就会被返回到最终结果
# 查询返回所有拥有至少两张发票的顾客
# 我的思路：先将invoices表按照顾客id分组,算清每个顾客id的发票数量,然后不知如何对比发票数
# MOSH :1. 上面我的第一步思路是对的，另外COUNT后面不用给他起名字是因为我们只需select顾客id一行
#       2. 第二步用HAVING语句筛选，因为是筛选分组后的发票数量数据！
#       3. 第三步放入子查询,返回顾客的信息，所以借助I N运算符/ = ANY 从clients表里找
/*USE sql_invoicing;

SELECT *
FROM clients
-- WHERE client_id IN (   #第一种方法:IN运算符
WHERE client_id = ANY (   #第二种方法: = ANY    两种方法相等，可自由选择
	SELECT 
		client_id
		-- COUNT(invoice_id) AS number_of_invoices
		-- COUNT(*)
	FROM invoices
	GROUP BY client_id    
	HAVING COUNT(*) >= 2
)    */


## 相关子查询----WHERE office_id = e.office_id,
# 相关子查询会进行表中项目数的次数，而上面的子查询只会执行一次。故当数据越大时，相关子查询占用的内存耗费的时间也就更多
# 因为这里子查询和外查询存在相关性, 在子查询中引用了外查询里出现的别名e，之前所写的子查询都是非关联子查询
# 例子：选择工资超过其所在部门的平均值的员工
# 由于这里返回的平均值不是确定的，而是每个office的平均值
/*USE sql_hr;
SELECT *
FROM employees e
WHERE salary > (
	SELECT AVG(salaray)
	FROM employees
	WHERE office_id = e.office_id  
    # 为什么不用GROUP BY？ 答：那子查询内必须有office_id这项，返回的就是两列表，不能和单值salary对比
    #这里相当于id相等时求平均数，
    #执行逻辑是：首先来到e员工表，对每位员工执行这段子查询，计算同一个部门平均工资；
    #当第一条记录员工工资高于平均值时，就会返回到最终结果。
    #然后是第二条记录也会计算所有同一部门员工的平均工资，相当于每条记录都会进行一次相应部门求平均工资
)     */

# 练习：查询返回那些高于每位客户所拥有发票平均值的发票
/*USE sql_invoicing;

SELECT *
FROM invoices i
WHERE invoice_total > (
	SELECT AVG(invoice_total)
    FROM invoices
    WHERE client_id = i.client_id
)
*/


## EXISTS运算符----数据量大时，能够提高效率
#  当我们使用EXISTS运算符时，子查询并没有给外查询返回一个结果，而是
#  	返回一个指令，说明这个子查询中是否有符合条件的行（一项）；
#  		如果TRUE，EXISTS运算符就会在最终结果里添加当前记录

# 查询返回有发票的客户，用IN运算符/JOIN两张表
#第一个方法：用IN运算符
# 如果数据量巨大，子查询部分就会形成一个数据量超大的列，妨碍最佳性能，可使用EXISTS运算符
/*SELECT *
FROM clients
WHERE client_id IN (   #显化子查询就是WHERE client_id IN (1,2,3,5,...)
	SELECT DISTINCT(client_id)
    FROM invoices
   -- GROUP BY client_id   #不需要这一步也可以实现
)     */

#第二个方法：用JOIN外连接，因为内连接只会得到有发票的客户项
/*SELECT *
FROM invoices i
LEFT JOIN clients USING (client_id)
WHERE invoice_id IS NOT NULL          */

#第三种办法：EXISTS和相关子查询结合
# 运行逻辑是:对于客户表里的每一位,都会执行一遍子查询,看是否存在EXIST符合子查询条件的项
/*SELECT *
FROM clients c
WHERE EXISTS (  #EXISTS运算符查看发票表里是否存在符合这个条件的行,而上面的例子是有对比项选择
	SELECT client_id
    FROM invoices
    WHERE client_id = c.client_id
)        */

#练习：从sql_store数据集中查询到从未被订购的产品product
/*USE sql_store;
#  方法一：用 NOT EXISTS和相关子连接（推荐）
SELECT *
FROM products p
WHERE NOT EXISTS (
	SELECT product_id
    FROM order_items oi
    WHERE product_id = p.product_id
)

#方法二：用IN运算符
SELECT *
FROM products 
WHERE product_id NOT IN (
	SELECT product_id
    FROM order_items     
)      /*
