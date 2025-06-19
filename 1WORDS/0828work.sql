## 如何将不同数据库里的多个表中的列合并到一起 
# 假设这sql_store里没有products表,将sql_inventory里的products表与oi表合并
/*SELECT *
FROM order_items oi    #简写oi
JOIN sql_inventory.products p  #因为现在我们默认用的是sql_store数据库，这是sql_inventory数据库里的表，注意标示
	ON oi.product_id = p.product_id  #这里是表内的列，标示出自表   */
    
#假如用sql_inventory表
/*USE sql_inventory;
SELECT *
FROM sql_store.order_items oi    #不是sql_inventory数据库里的表就需标识
JOIN products p 
	ON oi.product_id = p.product_id     */
    

## JOIN itself 将一个表内不同列以一个标准结合，逻辑过程可以想象为以不同列为基准的“两个表”的对应结合
# employees表中职员id和他们对应经理id,可以用作构建公司组织结构
/*USE sql_hr;

SELECT 
	e.employee_id,     #这里由于是一个表自身不同列的对应结合，
    e.first_name,      #所以也需加上以不同列为准的“表”的缩写标示
    m.first_name AS manager		
FROM employees e   #自定缩写
JOIN employees m  #表中对应的经理列reports_to
	ON e.reports_to = m.employee_id    #将返回e表的reports_to列对应m表的职员ID替换
    */

## 如何连接两个以上的表
# 将sql_store中的orders表与order_statuses表连接，
# 且需返回顾客表中的first,last name列——对应customer_id ；返回订单状态——基于order_status_id
/*USE sql_store;

SELECT 
	o.order_id,
    o.order_date,
    c.first_name,
    c.last_name,
    os.name
FROM orders o   #注意其他两个表都是以orders中列为对应基准的
JOIN customers c
	ON o.customer_id = c.customer_id
JOIN order_statuses os
	ON o.status = os.order_status_id       */

# 练习：将sql_invoicing里的payments表，payment_methods,clients表结合，
/*USE sql_invoicing;

SELECT 
	p.date,
    p.invoice_id,  #发票id
    p.amount,
    c.name,
    pm.name
FROM payments p
JOIN payment_methods pm
	ON p.payment_method =pm.payment_method_id  #pm表根据pm_id给p表填充名字
JOIN clients c
	ON p.client_id = c.client_id     #c表基于顾客id填充顾客名字       */


## 复合JOIN条件语句，对应复合主键表如何结合其他表填充数据，可用AND
#order_items表有两个主键，也称复合主键,分别为订单id和产品id
#order_items表中order_id有重复项，不能单独使用此列来唯一标识每条数据，product_id亦是
/*SELECT *
FROM order_items oi
JOIN order_item_notes oin
	ON oi.order_id = oin.order_id
    AND oi.product_id = oin.product_id         */     

    
## 隐式联合语法(记得WHERE语句）
/*SELECT *
FROM orders o, customers c
WHERE o.customer_id = c.customer_id        */  

#等同于以下显性连接（最好用显性JOIN）
/*SELECT *
FROM orders o
JOIN customers c
	ON o.customer_id = c.customer_id   */ 


## OUTER JOIN 外部连接，有两种LEFT JOIN 和 RIGHT JOIN, OUTER更像是跳出条件与否
# 只显示了有order的customer_id项，如果想看所有顾客订单，不管有没有order，这时用OUT JOIN
/*SELECT 
	c.customer_id,
    c.first_name,
    o.order_id
FROM customers c
-- JOIN orders o
-- LEFT JOIN orders o  #会返回左表（这里即customers表）所有数据不管满足ON条件与否
RIGHT JOIN orders o    #会返回右边即orders表所有内容，会和上面inner join结果相同，因为orders表指订单，而并不是每个顾客都会在此刻有order
	ON o.customer_id = c.customer_id   #只会返回显示符合此条件的行      */ 
    
# 练习：筛选出product_id, name, quantity三列数据，用到products和 order_items表
/*SELECT 
	p.product_id,   #需要是p.product_id，因为产品表里id是全的
    p.name,
    oi.quantity
FROM products p
LEFT JOIN order_items oi
	ON oi.product_id = p.product_id
ORDER BY p.product_id         */


## 如何在多个表间进行OUTER JOIN ，尽量只使用LEFT JOIN，避免LEFT RIFHT混用
#想要将shippers表中的名字填充连接到 orders和customers的连接表中
# 有些顾客没有运单人id,所以只返回了有shipper id的顾客id项目,
/*SELECT 
	c.customer_id,
    c.first_name,
    o.order_id,
    sh.name AS shipper
FROM  customers c   
LEFT JOIN orders o   #因为每一个顾客在此刻不一定都有订单
	ON o.customer_id = c.customer_id  
LEFT JOIN shippers sh       #因为不是每一个顾客都有运送人，所以用OUTER JOIN
	ON o.shipper_id = sh.shipper_id 
ORDER BY c.customer_id              */  

#练习：筛选出有order_date, order_id, first_name, shipper（包含null), status数列
/*SELECT 
	o.order_date,
    o.order_id,
    c.first_name AS customer,
    s.name AS shipper,
    os.name AS status
FROM orders o
JOIN customers c        
	ON o.customer_id = c.customer_id   
#因为每有一个订单肯定有一个顾客,所以ON后条件无论使用INNER JOIN还是OUTER JOIN都是有效的
JOIN order_statuses os
	ON o.status = os.order_status_id
#因为每一个订单都会有一个状态，所以可用INNER JOIN
LEFT JOIN shippers s
	ON o.shipper_id = s.shipper_id
# 因为不是每一个订单都有发货人,所以我们这要用OUTER JOIN,不然只会返回有shipper的订单
ORDER BY status                     */

/*总结：1. A （IN/OUT) JOIN B, 当A表对应列包含NULL值时，应用OUT） LEFT JOIN；
	    2. 当A表对应列Y 有重复但没有NULL值,但没有所有对应B表主键的值,没关系依旧用IN JOIN;
           (因为每一A表中的主键值Z都有一个 对应列Y的值了，继而将对应B表的值列返回)
        3. 当B表的对应列是该表主键Z时,而A表又无NULL值时,则肯定为IN JOIN;
           (因为代表着每一个A表对应列Y的值，都有一个唯一的B表Y列对应值）
		4. 当B表对应列Y不是主键列Z时，A表对应列Y为主键列Z时，用LEFT JOIN;
           (因为不是每一个A表对应列的值，都有B表对应列值的唯一对应）
		4. 若A,B表主键相同，则可以直接合并JOIN，ON后面跟两表的主键；          */