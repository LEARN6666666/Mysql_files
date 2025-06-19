## 如何插入、更新、删除数据
# 首先查看customers工具表，id列是数据类型是整数型，姓氏名字是varchar是可变长度的数据类型，()内为最大数字长度范围
# char--character, 数据类型是固定长度数据，char(5)意味着有五个字符串长度，如果只有两个字母，则系统会插入剩下三个空格来填充
# NN意味着这个数据列没有缺失值,AI意味着如果插入新数据，mysql会给新数据自动延续编号
# Default/Expression 意味着 birth日期与phone如果你不提供数据，会显示NULL值，points列你不提供数据，系统会自动使用‘0’


## INSERT INTO 语句——如何在表中插入单行
/*INSERT INTO customers
VALUES (
	DEFAULT,    #default用于为表中某一列设置默认值，即结果让系统生成针对客户ID的唯一值,因为AI框打钩了
    'John',     #接着提供first,last name列的值
    'Smith', 
    '1990-01-01',  # 接着是birth_date由于NN-Not Null没有打钩，意为可选不是必填项，所以可以给出一个日期或者NULL
	NULL,      #可输入DEFAULT 或者NULL结果都一样
    'address',
    'city',
    'CA',     # 因为state数据列限制字符2以内CHAR(2)
    DEFAULT)  #由于该列的数据类型，输入DEFAULT会返回0；或者具体值，因为它NOT NULL打钩了
*/

# 另一种方式,我们只需先定下填充数据的列名,VALUE后只需填这些数据具体的值)
/*INSERT INTO customers (
	first_name, 
    last_name, 
    birth_date,
    address,
    city,
    state)
VALUE (
	'John',   
    'Smith', 
    '1990-01-01',
    'address',
    'city',
    'CA')    #运行后再查看customers表，增加了一行数据      */


###  在一个表中一次性插入多行， 注意VALUES
/*INSERT INTO shippers (name)   #因为shipper_id系统自动生成了值，因为AI
VALUES ('Yean1'), 
	   ('Yean2'),
       ('Yean3')              


#练习：插入三行数据到product表
INSERT INTO products (
	name, 
    quantity_in_stock, 
    unit_price)
VALUES ('Yean1','50','1.10' ),    #数字可以不用单引号‘’，用了这也不会影响结果
	   ('Yean2', 60, 2.22),
       ('Yean3', 70, 3.33)
*/


## 将数据行插入到多个表中
# orders表与order_items表是父子表的关系,一个订单order可能有多个产品order items
# 如何插入order及其所有order items,注意order_items表中的order_id虽是主键，但并不是唯一的，不能令它自动生成
/*INSERT INTO orders (
	customer_id,
    order_date,
    status)
VALUES (1, '2019-01-02', 1 );

# MYSQL有很多内置函数build in function ,其中之一是LAST_INSERT_ID
# 会在我们插入新行时返回其ID,使用这个新返回的ID往order_items表中插数据
INSERT INTO order_items
VALUES 
	(LAST_INSERT_ID (), 1, 1, 2.95),
    (LAST_INSERT_ID (), 2, 1, 3.95)
# 因为insert_items表中所有列都是NOTNULL，所以我们可以不用输入列名称，直接插入值
*/ 


## 如何将一个表中的数据复制到另个表中
/*CREATE TABLE orders_archived AS
SELECT * FROM orders
*/ 
#执行语句后会发现，order_archived副表没有主键，也没有AI，所以如果你想在这个表插入数据，需要给orderid一个值
/*我们可以将SELECT * FROM orders作为sub query结合CREATE语句有强大的作用
1.首先选中orders_archived表，鼠标右键选中truncate table，因为我们要删除这个表内所有的数据
2.我们只想要从orders表中截取一些数据到oa表中(例为筛出2019年前的订单）
INSERT INTO orders_archived #不用给出每列名称，因为我们会给每列提供值
SELECT *
FROM orders
WHERE order_date < '2019-01-01'
#以上是将SELECT语句作为子查询subquery的示例
*/

/*练习：要求如下
1.联接invoices表和clients表，将client_id列替换为client_name列
3. ！！可以将这步放在复制表前面！！仅复制有付款的发票数据行（意味着选择payment_date有日期的行
2.在sql_invoicing数据库中，将经上操作过的表复制到invoices_archived表
 */
/*SELECT 
	i.invoice_id,
    i.number,
    c.name AS client_name,
    i.invoice_total,
    i.payment_total,
    i.invoice_date,
    i.due_date,
    i.payment_date
FROM invoices i
JOIN clients c
	USING (client_id) 
ORDER BY invoice_id
*/ #100%满分

/*CREATE TABLE invoices_archived AS
SELECT 
	i.invoice_id,
    i.number,
    c.name AS client_name,
    i.invoice_total,
    i.payment_total,
    i.invoice_date,
    i.due_date,
    i.payment_date
FROM invoices i
JOIN clients c
	USING (client_id) 
ORDER BY invoice_id ;
 
 SELECT *
 FROM invoices_archived
 WHERE payment_date IS NOT NULL   */
 # 上面答案是先做了复制的部分，然后筛选出支付日期符合的部分，但ia表内容没变
 
 #正确答案应先完成筛出条件步骤后的表，再进行复制
 /*CREATE TABLE invoice_archived AS    #第二步
 SELECT 
	i.invoice_id,
    i.number,
    c.name AS client_name,
    i.invoice_total,
    i.payment_total,
    i.invoice_date,
    i.due_date,
    i.payment_date
FROM invoices i
JOIN clients c
	USING (client_id) 
WHERE payment_date IS NOT NULL 
ORDER BY invoice_id
  */


## UODATE...SET语句——更新一个单行数据
#假设系统在这个数据上出现了问题，我们需要修改此数值,假设invoice表第一个行payment_total为10
/*UPDATE invoices
SET payment_total = 10, payment_date = '2019-03-01' #SET后跟我们需更新的值
WHERE invoice_id = 1 #通过此条件确定记录或者需要更新的记录
 */
#假设我们上面更新错了，我们需要更新3号数据，所以我们得先回到原始值
/*UPDATE invoices
-- SET payment_total = 0, payment_date = NULL
SET payment_total = DEFAULT, payment_date = NULL #因为pt的默认值是0，pd的是null
WHERE invoice_id = 1 
*/
#更新第三行数据,假设他开发票的时期正好是截止日期
/*UPDATE invoices
SET 
	payment_total = invoice_total * 0.5, 
	payment_date = due_date
WHERE invoice_id = 3 
*/

## 更新多行的数据
/*
UPDATE invoices
SET 
	payment_total = invoice_total * 0.5, 
	payment_date = due_date
-- WHERE client_id = 3       #假设更新client_id为3的顾客的数据条
WHERE client_id IN (3, 4)    # 更新顾客id为3,4的数据条
# 执行后会受到警告,因为mysql workbench会在safe update的模式下运行，它只会允许更新单条记录
解决方法：上方功能条Edit中preference建，之后选中左侧sql editor,然后右侧滑到最下方，
			取消saft update，之后关掉local im页面，重新点击打开复制执行。


# 练习：给额外50积分给那些在1990年前出生的顾客
/*USE sql_store;

UPDATE 	customers
SET points = points + 50
WHERE birth_date < '1990-01-01'
*/


##如何在update语句中使用子查询
/*UPDATE invoices
SET 
	payment_total = invoice_total * 0.5, 
	payment_date = due_date
WHERE client_id = 3  
#如果我们表中没有客户id怎么办,只有客户名字，用clients表
SELECT client_id
FROM clients	
WHERE name = 'Myworks' 
*/
#然后用下面这部分做上面的子查询
/*UPDATE invoices
SET 
	payment_total = invoice_total * 0.5, 
	payment_date = due_date
WHERE client_id IN    # 因为返回多条记录，所以不能用等号=，用IN
			(SELECT client_id
			FROM clients	
	        WHERE state IN ('CA', 'NY'))  */
# 如果不用子查询，也能返回结果
# 先做以下查询确认我们更新的内容没错，然后用子查询(删除select..from语句）
/*SELECT *
FROM invoices
WHERE payment_date IS NULL  
*/
/*UPDATE invoices
SET 
	payment_total = invoice_total * 0.5, 
	payment_date = due_date 
WHERE payment_date IS NULL 
*/

#练习：将积分超过3000的客户，comment更新为'Gold Customer',积分在customers表里
# 第一步 确认更新范围没错
/*USE sql_store;
SELECT *
FROM customers
WHERE points > 3000

# 第二步 利用子查询更新符合条件的表项
UPDATE orders
SET comments = 'Gold Customer'
WHERE customer_id IN 
					(SELECT customer_id   #注意select后面要改成对应条件列名称
					 FROM customers
					 WHERE points > 3000)
*/


## 删除数据
/*DELETE FROM invoices
WHERE invoice_id = 1 */
# 这里也可使用子查询——假设现在我们想删除所有客户名字叫Myworks项的数据
/*# 第一步 确认删除范围
SELECT *
FROM clients
WHERE name = 'Myworks'
# 第二步 删除符合条件的数据项
DELETE FROM clients
WHERE client_id = (
					SELECT *
					FROM clients
					WHERE name = 'Myworks') -----错误代码 不能用= ，且子查询不能对删除表clients的直接引用
 */
 
 
 ##恢复数据库，将所有的数据库恢复到原始状态
 /*操作方法：1.打开file选项条，选中open sql script，
			 2.打开create-databases.sql,然后点执行按钮去重建我们所有的数据库
             3.打开左侧navigator面板，刷新
 