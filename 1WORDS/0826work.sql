#
-- USE sql_store;

-- SELECT * 
-- from customers
-- where customer_id = 1    #语句前加上--符号代表不执行这行语句
-- order by first_name      #下面三个语句为语法结构，顺序不能变

-- SELECT *    #*代表的是表中列的部分
-- FROM customers

## 介绍 SELECT 语句

-- SELECT 
-- 	  first_name,
--    last_name, 
--    points, 
--    points * 10 + 100  AS 'discount_factor'  #创新的一列，注意列名称用‘’标示
    -- (points+10) * 100   # 搜索列还可进行数学运算;
-- FROM customers


## 介绍distinct语句 以及如何修改表中数据
 #介绍了如何修改表中数据——双击修改，后点击右下角apply确认
 #去除重复项，比如说想知道分布在哪些城市，有很多重复的数据
 
 -- SELECT DISTINCT state    
 -- 	FROM customers 

#小练习
/* 可以作为整段注释的开头 作为结尾的是*/
/* SELECT 
	name, 
    unit_price,
    unit_price * 1.1 AS ' new price '
FROM products */   


## 介绍 WHERE 语句, WHERE后跟的是一个条件
#运算符表示有> 大于， >=大于等于， <小于， <=小于等于， != 和 <> 都代表不等于
# 字符串字符序列都需要用‘’或“”标识
#比较运算符也可运用到日期上

/*SELECT *
FROM customers
-- WHERE points > 3000
-- WHERE state != 'VA'
WHERE birth_date > '1990-01-01' */

#小练习
/*SELECT *
FROM orders
WHERE order_date >= '2018-01-01' */


## 如何筛选数据时合并多个搜索条件 
# AND 两者都得符合means“且”——交集；OR 意味着“或”——并集
# 逻辑运算符的顺序 AND 是先于OR的，就像是先乘除后加减,同理括号应用首先运算括号内的
# NOT运算符应用,当后面多个条件时，一定要记得使用括号（）
/*SELECT *
FROM customers
-- WHERE birth_date > '1990-01-01' OR (points > 1000 AND state = 'VA')
# OR并的两个条件是1.大于1991年出生的 2.分数大于1000且州在VA的

-- WHERE NOT (birth_date > '1990-01-01' OR points > 1000)
-- WHERE birth_date <= '1990-01-01' AND points <= 1000 */

#练习，从order_items表中，筛选出6号order所有消费超过30的记录
/*SELECT *
FROM order_items
WHERE order_id = 6 AND (quantity * unit_price > 30) */


##运算符IN的应用
#OR运算符是连接组合两个条件表达式，不能连接两个字符串
/*SELECT *
FROM customers
-- WHERE state = 'VA' OR state = 'GA' OR state = 'FL'
WHERE state NOT IN ('VA', 'GA', 'FL') */

#练习 筛选出products表中quantity_in_stock等于49,38,72的记录
/*SELECT *
FROM products
WHERE quantity_in_stock IN (49, 38, 72) */


## BETWEEN运算符的应用，包括前后两个范围数字，也可运用于两个日期
/*SELECT *
FROM customers
-- WHERE points >= 1000 AND points <= 3000
WHERE points BETWEEN 1000 AND 3000 */

#小练习：筛选出customers表中出生日期在1990-01-01到2000-01-01之间的人
/*SELECT *
FROM customers
WHERE birth_date BETWEEN '1990-01-01' AND '2000-01-01' */


## LIKE运算符-学习如何筛选与特定字符串匹配的行
#其中 % 代表任意数量的字符—,且放在哪个位置都可以
#其中 _ 下划线匹配单个字符，'_y'代表以y结束的两个字符长度的项目
/*SELECT *
FROM customers
-- WHERE last_name LIKE 'b%'   #以b开头的所有客户,b大小写也没关系
-- WHERE last_name LIKE '%B%'  #名字中只要包含了b字母的都会被筛选
-- WHERE last_name LIKE '_____y' # 5个_代表前面5个字符
WHERE last_name LIKE 'b____y' */

#小练习：1.筛选出customers表中address包含TRAIL或者AVENUE的项目
/*SELECT *
FROM customers
WHERE address LIKE  '%TRAIL%' OR      #注意！！OR连接的是两个条件表达式，而不是字母串
	  address LIKE  '%AVENUE%'  */ 
# 2. 从customers表中筛选出phone号码以9结尾的项目
/*SELECT *
FROM customers
WHERE phone LIKE '%9' */