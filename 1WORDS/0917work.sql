## 创建视图——可将一些查询或子查询存到视图内
# 当我们使用了好几个链接和子查询时，这时可以使用视图来解决繁琐的查询了 
/*USE sql_invoicing;

CREATE VIEW sales_by_client AS  #这句语句后的SELECT就是创建的试图内容，
SELECT 
	c.client_id,
    c.name,
    SUM(invoice_total) AS total_sales
FROM clients c
JOIN invoices i USING (client_id)
GROUP BY client_id, name      */     

#执行语句后并不会返回结果，而是刷新项目栏后，查看VIEWS文件夹，可从其下视图中像表格那样选择处理数据 
/*SELECT *
FROM sales_by_client
-- ORDER BY total_sales DESC
-- WHERE total_sales > 500
JOIN clients USING(client_id)       

#视图不存储数据，像张虚拟表，我们的数据只存在了表中
#练习： 创建一张视图显示每位客户的结余,表名称叫clients_balance,需包含三列client_id,name,balance(结余）
/*CREATE VIEW clients_balance AS
SELECT 
	i.client_id,
    c.name,
    SUM(invoice_total - payment_total) AS balance  #发票总额-支付总额
FROM invoices i
JOIN clients c USING (client_id)
GROUP BY client_id, name
 */
 
 
 ##2. 更新/删改视图——两种方法
 #1）删除视图并重新创建: 结尾不用冒号，之后刷新项目面板；重新创建就重新执行修改后语句就好
 -- DROP VIEW sales_by_client  
 
 # 2)第二种方法：使用REPLACE关键字，（更推荐！） 
 /*CREATE OR REPLACE VIEW sales_by_client AS  #直接修改
SELECT 
	c.client_id,
    c.name,
    SUM(invoice_total) AS total_sales
FROM clients c
JOIN invoices i USING (client_id)
GROUP BY client_id, name 
*/

#如果找不到创建视图的那段查询语句了怎么办？  
/* 1. 源码控制：单独保存查询到VIEW文件夹电脑中(最好的方式！)
2. 在对应视图右侧点开工具标识,直接在那页面上修改
    写完了就点击右下角应用apply
*/


##3. 可更新视图：视图中没有 DISTINCT关键字/任何聚合函数/ GROUP BY /HAVING/ UNION运算符
#可在INSERT， UPDATE, DELETE语句中使用这类视图
# 在invoices表的基础上创建一个有结余列的表
/*CREATE OR REPLACE VIEW invoices_with_balance AS
SELECT
	invoice_id,
    number,
    client_id,
    invoice_total,
    payment_total,
    invoice_total - payment_total AS balance,
    invoice_date,
    due_date,
    payment_date
FROM invoices
WHERE (invoice_total - payment_total) > 0  #这里不能用balance别名
*/
#上面就是个可更新视图，可在这中视图中删除记录，就像普通的表一样
/*DELETE FROM invoices_with_balance
WHERE invoice_id = 1   # 执行后刷新表单   */

#更新表单，把2号发表的到期日期due_date推迟两天
/*UPDATE invoices_with_balance
SET due_date = DATE_ADD(due_date, INTERVAL 2 DAY)
WHERE invoice_id = 2   
# 执行后刷新表单   */

#插入新发票项目:必须插入视图中所有列的项值才会生效
#有时候我们可能没有某张表的直接权限,所以只能通过视图修改数据，前提是你们的视图是可更新的视图


## 4.WITH OPINION CHECK语句 ——会防止UPDATE/DELETE语句将视图中的数据删除
#试着更新上面invoice_with_balance表中一张发票invoice_total= payment_total
/*UPDATE invoices_with_balance
SET payment_total = invoice_total
WHERE invoice_id = 2     */
#结果会发现2号发票记录没有了,如果你不希望在使用delete/update这样的语句时误删一些数据,
# 则可以在创建这张视图的语句最后加上“ WITH CHECK OPTION "
/*CREATE OR REPLACE VIEW invoices_with_balance AS
SELECT
	invoice_id,
    number,
    client_id,
    invoice_total,
    payment_total,
    invoice_total - payment_total AS balance,
    invoice_date,
    due_date,
    payment_date
FROM invoices
WHERE (invoice_total - payment_total) > 0
WITH CHECK OPTION 
#重新执行上面语句，然后刷新

#试着重做一次实验，这次是针对发票id为3的记录
UPDATE invoices_with_balance
SET payment_total = invoice_total
WHERE invoice_id = 3
#结果显示执行错误，防止误删数据 
*/


## 5. 视图的其他优点 
/* 1)简化查询语言（上述都有提到）
   2）可以减小数据库设计改动的影响——修改视图的话，恢复查询原数据还可以用到invoices表（有后援
   3）限制基础表访问，加强数据安全性
*/