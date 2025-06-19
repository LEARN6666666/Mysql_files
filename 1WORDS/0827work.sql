## REGEXP 运算符用法——Regular Expression正则表达式,在搜索字符串时功能更强大
#like 用法与REFEXP用法区别
# REGEXP ‘^field’以field开头；REGEXP 'field$'以field结尾
# | 符号的应用，表示或的意思以及组合应用
# []符号的应用，像是作为各单个字符的集合,还可输入范围
/*SELECT *
FROM customers
-- WHERE last_name LIKE '%field%' 
-- WHERE last_name REGEXP 'field'   #结果同于上方like表达式
-- WHERE last_name REGEXP '^field'   #意为必须以field开头
-- WHERE last_name REGEXP 'field$'
-- WHERE last_name REGEXP 'field|mac'  #筛选出姓氏中有field 或 mac的项目
-- WHERE last_name REGEXP '^field|mac|rose'  # 意为筛选出姓氏中以field为开头或者包含mac或包含rose的选项
-- WHERE last_name REGEXP '[gim]e' # 筛选出last_name中包含ge,ie,me的选项,e不一定是整个姓氏结尾
-- WHERE last_name REGEXP 'e[fmq]'
-- WHERE last_name REGEXP '[a-h]e'     # [a-h]e意为筛选出a到h范围中的所有字母与e的组合 */

#小练习：1.筛选customers表中first_name是ELKA或者AMBUR的数据
/*SELECT *
FROM customers
WHERE first_name REGEXP 'ELKA|AMBUR' */

#2.筛选出last_name以EY 或者 ON结尾的数据
/*SELECT *
FROM customers
WHERE last_name REGEXP 'EY$|ON$'  */

#3.筛选出last_name以MY为开头 或者包含SE的数据
/*SELECT *
FROM customers
WHERE last_name REGEXP '^MY|SE'  */

#4.筛选出last_name包含 BR或者BU
/*SELECT *
FROM customers
WHERE last_name REGEXP 'B[RU]'    */


## IS NULL 运算符——如何查找缺失值项目
/*SELECT *
FROM customers
-- WHERE phone IS NULL
WHERE phone IS NOT NULL  #注意NOT的位置  */

#练习:筛选出尚未发货ship的数据
/*SELECT *
FROM orders
WHERE shipper_id IS NULL    */


## ORDER BY 运算符如何对查询数据进行排序
#解释主键：每个表右侧的工具键展示该表的一些主要信息，每个表都有一个主键列，
#而主键列的数据应唯一标识该表中的记录，自动按照主键顺序排序
# DESC的用法，在结尾表示逆序 Descending
# 多种排序条件结合，用逗号 ，前后表示顺序优先级
/*SELECT *
FROM customers
-- ORDER BY first_name    #按照名字顺序排序表格
-- ORDER BY first_name DESC   #逆序
-- ORDER BY state, first_name   #先按照state排序，后以前面的结果为基础再以first name排序
-- ORDER BY state DESC, first_name DESC    */

## MYSQL与其他数据管理库工具不同的是，mysql可以排序表中任何列，不论它有没有被SELECT
# ORDER BY 1, 2可以用但最好不要，不利于后面进一步查询，会造成混乱
-- SELECT first_name, last_name
-- SELECT *
/*SELECT first_name, last_name, 10 AS points  # points不是表中有效列，只是一个别名
FROM customers
-- ORDER BY birth_date  #表会按照选中排序的列，不论它是不是被select的列
-- ORDER BY points, first_name
ORDER BY 1, 2 #这里的1,2代表select后的第一个，即first_name和第二个，即last_name    */

# 练习：筛选出order_id为2，且根据总价从多到少排序
/*SELECT *, quantity * unit_price AS total_price
FROM order_items
WHERE order_id = 2
-- ORDER BY quantity * unit_price DESC  #ORDER BY后也不一定是图中参数列，也可以是表达式
ORDER BY total_price DESC      */



## LIMIT语句——如何限制查询返回的记录
# 在网站分页上能应用
# LIMIT 语句的顺序始终是最后
-- SELECT *
-- FROM customers   #返回所有customers表的数据

/*SELECT *
FROM customers
-- LIMIT 3
#page 1: 1-3  page 2: 4-6  page 3: 7-9
#我们想跳过1,2页，获取第三页的信息
LIMIT 6, 3  #这里的6代表偏移量offset, 3表示获取3条记录     */

# 练习：筛选出前三位忠诚的客户——意味着积分points最多
/*SELECT *
FROM customers
ORDER BY points DESC
LIMIT 3    */


## JOIN（两种类型） ——如何从多个表中选择列展示
# INNER实际上是可选择性键入的，所以可省略
# ON 短语连接,后跟条件
#如何在orders表中选择订单，但不显示客户id，而是显示顾客的全名（在customers表中）
/*-- SELECT *        #在orders表的技术上join加上customers表，但顾客id要对应
-- SELECT order_id, first_name, last_name   #后两列是customers表中的
SELECT order_id,  orders.customer_id, first_name, last_name
# 需要注意customer_id两个表中都有，所以注意添加限定表格.
FROM orders     
INNER JOIN customers 
	  ON orders.customer_id = customers.customer_id      */
      
#用别名简化重复表格名称,将其缩写
/*SELECT order_id,  o.customer_id, first_name, last_name
FROM orders o   #跟在FROM, JOIN表名称后面
INNER JOIN customers c
	  ON o.customer_id = c.customer_id       */

#练习：返回products表中的product_id和name,以及order_items中的quantity和unit_price
# 当select项两个表内都有时，需要标识一个表的简称示归属
#注意这里两个表中的unit price并不相同,oi表中是下订单时的价格，p表中是当前价格,需要用oi的来计算销售额
/*SELECT oi.product_id, name, quantity, oi.unit_price 
FROM products p
JOIN order_items oi
	ON p.product_id = oi.product_id      */
