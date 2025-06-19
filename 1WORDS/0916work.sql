## 1. 数值函数(ROUND, TRUNCATE, CEILING, FLOOR, ABS, RAND,其他的google搜mysql  numeric functions
#Mysql内最有用的一些内置函数，用以应对数值、日期时间和字符串
#处理数值数据的函数，ROUND函数——四舍五入数字,并且还有第二个参数可以指定精确度。
-- SELECT ROUND(5.73, 1) #保留了一位小数做四舍五入
-- SELECT ROUND(5.7345, 2)   #保留两位小数

#TRUNCATE函数，截断数字，不管四舍五入
-- SELECT TRUNCATE(5.7365, 2)

#CEILING函数--上限函数，会返回大于等于>=括号中数值的最小整数
-- SELECT CEILING(5.73)

#FLOOR函数——下限函数，会返回小于等于<=这个数字的最大整数
-- SELECT FLOOR(5.73)

#ABS函数，用来计算绝对值
-- SELECT ABS(-5.73)

#RAND函数——用来生成0-1区间的随机浮点数，每次调动都会生成一个新的随机值
-- SELECT RAND()


## 2. 字符串函数——处理字符串数据的函数(其他的google搜mysql  string functions
# LENGTH, UPPER/LOWER, TRIM/LTRIM/RTRIM, LEFT/RIGHT/SUBSTRING, LOCATE, REPLACE, CONCAT
# 1)LENGTH函数：得到字符串的字符数
-- SELECT LENGTH('sky')

# UPPER 和 LOWER函数，可以将字符串转化成大写或小写字母
-- SELECT LOWER('sky')

# 2)删除字符串中不需要的空格——TRIM, LTRIM, RTRIM, 
#在处理用户输入的数据极其有用，因为有的人在输入前后多余的空格 
# LTRIM (LEFT TRIM）的简写
-- SELECT LTRIM('   sky')

-- SELECT RTRIM('sky    ')

-- SELECT TRIM('   sky    ')  #会删除前后所有空格

# 3)字符截取函数:LEFT, RIFHT, SUBSTR函数
#LEFT函数截取字符串前几个字符 ,RIFHT相对从右边开始
-- SELECT LEFT('responsibility', 4)
-- SELECT RIGHT('responsibility', 4)

#SUBSTRING函数:可以得到一个字符串中任何位置的字符,第二个参数是起始位置,第三个参数是截取长度
# 如果不输第三个参数,会返回从起始位置之后的所有字符
-- SELECT SUBSTRING('responsibility', 4,5)

# 4)LOCATE函数：返回第一个字符或者一串字符的匹配位置数值点 
# 第一个参数是我们想要搜索的字符,只会返回我们搜索字符的第一个位置数值，后面的不会返回 
-- SELECT LOCATE('i','responsibility')

# 如果搜索字符串里没有的字符会怎样？——会得到0，和其他编程语言会得到-1不同
-- SELECT LOCATE('q','responsibility')

#搜索字符串时，会返回第一次出现的开头字符的位置数值点 
-- SELECT LOCATE('pons','responsibility')

# 5) REPLACE替换字符
# 第一个参数是主字符串, 第二个参数是你想替换的主字符串里的一部分字符， 第三个是你想替换成的字符串
-- SELECT REPLACE('responsibility', 'ibility', 'e')

# 6) CONCAT串联两个字符串 
-- SELECT CONCAT('respon', 'sibility')
# 用在处理数据表上时，可以合并姓first_name和氏last_name 两栏字符形成名字 
/*USE sql_store;

SELECT CONCAT(first_name, ' ', last_name) 
# 注意这里不要打引号了，因为这里是列名，不是单纯字符串连接; 另外中间加空格需要引号
FROM customers
*/


# 3. 日期函数
# NOW 函数， 调用当前的日期和时间 
# CURDATE 函数：会把时间去掉，只返回当前日期
# CURTIME :只会返回当前的时间
-- SELECT NOW(), CURDATE(), CURTIME()

#2）YEAR, MONTH, DAY, HOUR, MINUTE, SECOND用以提取特定的日期或者时间的构成元素
#YEAR函数:返回当前时间的年份,YEAR后括号内不能空
-- SELECT YEAR(NOW())
-- SELECT MONTH(NOW())
-- SELECT DAY(NOW())
-- SELECT SECOND(NOW())

# 3）返回字符串的两种函数: DAYNAME, MONTHNAME
-- SELECT DAYNAME(NOW()) #会返回字符串形式的星期数，不是DAY会返回几号 
-- SELECT MONTHNAME(NOW())  # 会返回字符串形式的月份，而不是MONTH的数字

# 4) EXTRACT标准的sql语言，如果想要把代码录入别的数据管理工具，最好用EXTRACT函数
# 括号内首先输入想获取的单位，然后是FROM 最后是时间日期值
-- SELECT EXTRACT(DAY FROM NOW())

#练习：修改以下语句，得到确切的在当年下的订单
/*SELECT *
FROM orders
WHERE order_date >= '2019-01-01' 
#这种返回当年年份的订单方式不怎么样,会把之后2020年的也返回    
SELECT *
FROM orders
WHERE YEAR(order_date) >= YEAR(NOW()) #因为现在已经2024年，而数据表里只有2019年前的数据，所以不会返回任何结果
# 先用NOW返回现在的时间日期，再传递给YEAR函数，提取当前年份，同样利用YEAR得到订单年份，再进行比较
*/

##4. 格式化日期和时间 ：DATE_FORMAT, TIME_FORMAT (其他的google搜mysql date_format string
#'2019-03-22'这种格式不适合用户观看，格式化日期和时间的函数
# 1) DATE_FORMAT 俩参数，第一个日期值，第二个格式字符串，后者包含了格式化日期的几个构成成分的特殊代码
-- SELECT DATE_FORMAT(NOW(),'%y')  # %y表示两位的年份
-- SELECT DATE_FORMAT(NOW(),'%Y')  #Y表示四位的年份
-- SELECT DATE_FORMAT(NOW(),'%m %y')  # %m表示两位的月份
-- SELECT DATE_FORMAT(NOW(),'%M %Y')  #  %M表示月份名称
-- SELECT DATE_FORMAT(NOW(),'%M %d %Y')

# 2) TIME_FROMAT思路与上相似，但是会用其他格式说明符
-- SELECT TIME_FORMAT(NOW(),'%H:%i %p') #%H表示时间,%i表示分钟，%p表示pm/am


## 5. 计算日期和时间的函数: DATE_ADD/DATE_SUB俩参数, DATEDIFF
# 1）例如我们想在日期基础上增加/减少一天或者一个小时,或者计算两个日期的间隔
# DATE_ADD函数,给日期时间值添加日期值 ,第二个参数要写一段表达式
-- SELECT DATE_ADD(NOW(),INTERVAL 1 DAY) #在今天同一时刻的基础上加1天 
-- SELECT DATE_ADD(NOW(),INTERVAL 1 YEAR)  #加一年
-- SELECT DATE_ADD(NOW(),INTERVAL -2 DAY)  #想返回过去的时间，直接加个负号
-- SELECT DATE_SUB(NOW(),INTERVAL 2 DAY)  #或者使用DATE_SUB函数 

#2）DATEDIFF函数 / TIME_TO_SEC函数：计算两个日期/时间的间隔
# DATEDIFF函数：一般是离现在越近的日期放在前面，远的放在第二个，不然会返回负数
-- SELECT DATEDIFF('2024-01-01', '2024-09-16') #只会返回天数，不会有小时分钟

#TIME_TO_SEC函数：计算两个时间内的间隔
-- SELECT TIME_TO_SEC('9:00') #从午夜到九点的秒数
-- SELECT TIME_TO_SEC('9:00') - TIME_TO_SEC('9:15') #返回两时间内的间隔


## 6. IFNULL和COALESCE函数
#有很多shipper_id是NULL, 我们想要让用户看到的是“未分配”标签，而不是空值 
# IFNULL函数
/*USE sql_store;

SELECT 
	order_id,
    IFNULL(shipper_id, 'NOT assigned') AS shipper
    #如果第一个参数代表列中有空值，用第二个参数字符串‘’代替
FROM orders       */

# COALESCE函数: 括号内可提供一堆值，返回这些值中第一个非空值
#假设发货人id列有空值，你想要返回第二个参数注释列的值，如果注释备注也是空值，那就返回第三个参数‘未分配’
/*SELECT 
	order_id,
    COALESCE(shipper_id, comments, 'NOT assigned') AS shipper
FROM orders         */

# 练习：返回顾客的姓氏为一列，还有对应的电话号码/100/
/*SELECT 
	CONCAT(first_name, ' ',  last_name) AS customer,
    COALESCE(phone, 'Unknown') AS phone
FROM customers
*/


## IF 函数——根据条件成立与否，返回不同的值
#IF(expression, first, second),如果正确T返回第一个值,如果错误F返回第二个值,这值可以是字符串/数字/空值/日期等
# 在orders表中，如果订单说是今年的，分为“活跃”档，如果是之前的，则分为"归档“类别
#之前是用UNION函数，连接两个语句结果行：一个SELECT得到活跃订单，一个SELECT得到归档订单
/*SELECT
	order_id,
    order_date,
    IF(YEAR(order_date) = YEAR(NOW()), 'active', 'Archived') AS category
FROM orders


#练习：查询返回四列product_id, name(产品名字), orders每个产品的订单数，
#          frequency（根据第三列订单数，多于1的"many times",否则“once”
# 这没要求呈现无订单的产品7，不然就要用LEFT JOIN
# 自己的答案牛逼!——顾虑到只有oi表中可用COUNT计算每个产品的订单数，所以以oi表为母表，加了个子查询
/*SELECT
	product_id,
    (SELECT name 
    FROM products 
    WHERE product_id = oi.product_id) AS name,
	COUNT(order_id) AS orders,
    IF(COUNT(order_id) > '1', 'Many times', 'Once') AS frequency 
FROM order_items oi
GROUP BY product_id         */

#老师的答案思路：以products表为母表，J先OIN连接products表和oi表,后分组，前两列省事儿
/*归根结底COUNT(*)是对上一步结果做计数,而不是真的对于数据来源表做计数,
LEFTJOIN会使以products表为主，返回它的所有项
（是从products表中返回的产品id和名字，所以产品7是不受oi表有没有影响的)
而之后的count是计LEFT JOIN连接后的数，而并不是真实有订单的订单数量，
其他重复的产品id和名字是从oi表来的，而产品7的数据是来源于p表的,所以只能用JOIN返回两边都有的项 */
/*SELECT
	product_id,
    name,
    COUNT(*) AS orders #因为我们这使用了聚合函数，所以需要用上两列来分组
    -- IF(COUNT(*) > 1, 'Many times', 'Once') AS frequency 
FROM products
JOIN order_items USING (product_id)
GROUP BY product_id, name
 */
 
 
 ## CASE运算符——CASE...WHEN...ELSE...END
 #如果我们有好几个表达式需要测试怎么办？
 /*SELECT
	order_id,
    CASE
		WHEN YEAR(order_date) = YEAR(now()) THEN 'Active'
        WHEN YEAR(order_date) = YEAR(now()) - 6 THEN '2018 年'
        WHEN YEAR(order_date) < YEAR(now()) - 6 THEN 'Achived'
        #如果THEN前表达式为T，则返回THEN后的值
        ELSE '2018-2024年'
        #如果以上条件都不为真，则返回ELSE后的结果
        END AS category 
        #用end关闭CASE语句块
FROM orders
*/

# 练习：查询返回三列customer(姓氏都有), points(从高到低排列），category(根据顾客的积分做了等级分类） 
# 超过3000分，就是GOLD, 在2000-3000之间就是Sliver, 在2000以下就是Bronze
# 之前写过同样的例子，但是是用UNION连接三段查询语言的
SELECT
	CONCAT(first_name, ' ', last_name) AS customer,
    points,
    CASE
		WHEN points > 3000 THEN 'Gold'
        -- WHEN points BETWEEN 2000 AND 3000 THEN 'Sliver' #这也可以稍微优化一下 
        WHEN points >= 2000 THEN 'Sliver' 
        #因为如果大于3000，在第一个语句就通过了，剩下的都是小于等于3000的
	ELSE 'Bronze'
    END AS category
FROM customers
ORDER BY points DESC
# 自己的答案100分/