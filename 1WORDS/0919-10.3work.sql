## 1. 什么是存储过程？
/* 假如你要编写一个应用，应用里有个数据库，要在哪写sql语句，你不能在你的应用代码里写sql语句 
因为假如你在C++/Java/Python中开发应用，又加上sql语句，这两者的编程语言不同，
一 会造成代码混乱，难以维护, 二 由于C++/Java语言需要编译工作，必须重新编译sql中的语言才能生效 
所以需要将sql存储到它应属的数据库里，放在存储过程或者函数中。
*/
# 存储过程是一个包含一堆sql代码的数据库对象， 在我们的应用代码里，我们调用这些过程来获取或保存数据。 
# 1）存储管理sql代码   2）sql代码执行数据更快  3）能加强安全性

## 2.创建一个存储过程 
#给创建视图取名字时，需要小写且中间用下划线连接
# BEGIN 和END之间的内容是存储过程的主体(BODY)
/*CREATE PROCEDURE get_clients()  # 括号内添加参数,给存储过程传递值
BEGIN
	SELECT * FROM clients;         #这是需要存储的查询,不管有几句,后面都得加冒号;
END
 #上面的不要执行，有语法错误 

#想让mysql为整体创建一个存储过程，而不是几行分离的代码
*/ 

#改成国际通用$$,告诉mysql这是新的分隔符,将分号改成$$
#END重复$$，告诉mysql以上是个整体 ，最后把默认分隔符改回分号;
#在其他的DBMS比如sql server你不需要改动默认分隔符 
#执行以下程序后，打开导航面板刷新,点击get_clients右边的闪电标执行显示该存储过程
#！！！注意：创建存储过程时，代码中间不能有注释，不然会没反应！！
/*
DELIMITER $$       
CREATE PROCEDURE get_clients()  
BEGIN
	SELECT * FROM clients;      
END$$               

DELIMITER ;  
*/

#2) CALL语句调用存储过程
-- CALL get_clients()
# 大多数时候，我们会用C++、JAVA、python等的应用代码调用存储过程

#练习： 创建一个名为get_invoices_with_balance的存储过程，去返回所有结余>0的发票 
/*
DELIMITER $$
CREATE PROCEDURE get_invoices_with_balance()
BEGIN
	SELECT * FROM invoices
    WHERE invoice_total - payment_total > 0;
END$$

DELIMITER ;
*/
# 我们改动默认分隔符DELEMITER的原因就是：为了sql语言，主体部分能够顺利执行，能够使用分号； 
/*中间主体body部分也可以应用view视图 
SELECT *
FROM invoices_with_balance 
WHERE balance > 0
*/

## 3.使用MYsql工作台创建存储过程 
#因为每次创建存储过程都要改默认分隔符, 所以有以下简单的办法 
/*在导航面板,右键点击"Stored Procedures"项目栏, 选择" CREATE stored procedure"
会跳出一个BODY主体部分空白的代码页，先改一下新的存储过程的名字'get_payments',
再加上主体部分代码 SELECT * FROM payments;
最后点击右下角的应用APPLY选项,会跳出mysql生成的sql语句，继续点apply. 
*/

## P71 删除存储过程 
# 语句后不用加分号
-- DROP PROCEDURE get_clients 
# 1.为了防止错误出现，我们可是使用IF EXISTS关键字
-- DROP PROCEDURE IF EXISTS get_clients   
/* 2.像视图一样，最好把删除和创建每一个存储过程的代码放在不同的sql文件中,
并把文件放在Git那样的源代码控制下，团队其他成员可以从中获取VIEW 和PROCEDURE 代码 
*/
/*
DROP PROCEDURE IF EXISTS get_clients;

DELIMITER $$
CREATE PROCEDURE get_clients()
BEGIN
	SELECT * FROM clients;
END$$

DELIMITER ;
*/
# 把以上存储过程的代码存在一个叫‘get_clients’的文件里——单独开一个查询页面，保存文件命名get_clients
# 把这些所有代码放进git源代码空值，就能随时回来查看你对数据库对象做的改动。


## P72 参数 
# 如何在存储过程中添加参数，我们一般使用参数为存储过程传递值，也可以使用参数为调用程序赋值 
# 1. 我们这上面已有一个get_cliets的存储过程，让我们创建一个新的存储过程叫'get_clients_by_state'
# 想让存储过程获取州名，并返回那个州的客户，所以在括号中间加上一个参数,并把数据类型设置为CHAR(2)
#CHAR(2)代表了有两个字符的字符串,VARCHAR表示可变长度的字符串
/*  2.如何添加WHERE条件？
1)有些人喜欢给系数添加前缀或者后缀，像p_state;
2)(推荐)给表格起一个别名c,然后为列加上表别名,结果就是把clients表里的州这列的值跟定义的州系数作对比
*/
/*
DROP PROCEDURE IF EXISTS get_clients_by_state;

DELIMITER $$
CREATE PROCEDURE get_clients_by_state
(
	state CHAR(2)
)
BEGIN
	SELECT * FROM clients c
    WHERE c.state = state;
END$$

DELIMITER ;
*/

#执行以上过程后，刷新导栏，后新建个查询，调用CALL这个存储过程Procedure
#参数使我们自己选择填写的，CA——加州 
# 如果我们不填写参数值，会怎么样？——会出现错误，因为MYSQL里的所有参数都是必填的 
-- CALL get_clients_by_state('CA')  

#3.练习—— 写一个能返回给定客户id系数(数据类型参考原表INT)的发票的存储程序，名字是'get_invoices_by_client'
# 我的答案:
/*
DROP PROCEDURE IF EXISTS get_invoices_by_client;

DELIMITER $$
CREATE PROCEDURE get_invoices_by_client
(
	 client_id INT
)
BEGIN
	SELECT * FROM invoices i
    WHERE i.client_id = client_id;
END$$

DELIMITER ;
/*
#MOSH老师的:直接右键创建一个存储过程操作，填入代码apply后执行；
/*4.如何调用这个存储程序？
除了CALL语句，还可直接点击右边执行闪电标记，
会跳出个小框让你填写你想要查询的值,执行后返回。 
*/


## 9.23 P73 带默认值的参数（为参数配置默认值） 
# 接着使用之前创建的过程‘get_clients_by_state’
# 1. 如果调用者无法明确具体在哪个州, 那么就默认返回加州的客户IF...THEN...SET...END
/*
DROP PROCEDURE IF EXISTS get_clients_by_state;

DELIMITER $$
CREATE PROCEDURE get_clients_by_state
(
	state CHAR(2)
)
BEGIN
	IF state IS NULL THEN
		SET state = 'CA';
	END IF;
	SELECT * FROM clients c
    WHERE c.state = state;
END$$

DELIMITER ;
*/
# 接着使用空值调用这个过程,打开一个新的查询页面，调用这个程序 
-- CALL get_clients_by_state(NULL)
# 所以参数括号内必须填入一个值,包括空值NULL,不然mysql会报错

# 2.功能强大的小技巧
/* 如果我们不只是返回位于CA加州的客户，而是返回所有客户，怎么做？
1)不再为系数设一个默认值，可以写如下的分段查询； IF...ELSE...END IF
(这个办法使得代码过于麻烦复杂，看着也不专业)*/
/*DROP PROCEDURE IF EXISTS get_clients_by_state;

DELIMITER $$
CREATE PROCEDURE get_clients_by_state
(
	state CHAR(2)
)
BEGIN
	IF state IS NULL THEN
		SELECT * FROM clients;
	ELSE
		SELECT * FROM clients c
		WHERE c.state = state;
	END IF;
    
END$$

DELIMITER ;
*/

# 2）可以将上面if...else..两段查询合并为一段查询—— 改WHERE语句中IFNULL
/* c.state = IFNULL(state, c.state) 意思是: IFNULL如果第一个参数值是空值,就会返回第二个参数值
如果state是空值，则返回c.state,所以WHERE语句实则为WHERE c.state = c.state,这个条件永远都正确*/
/*
DROP PROCEDURE IF EXISTS get_clients_by_state;

DELIMITER $$
CREATE PROCEDURE get_clients_by_state
(
	state CHAR(2)
)
BEGIN
		SELECT * FROM clients c
		WHERE c.state = IFNULL(state, c.state);    
END$$

DELIMITER ;
*/

# 练习：写一个叫'get_payments'的存储过程,
/* 带两个参数client_id(数据类型INT) 和payment_method_id（数据类型TINYINT）——整数的不同类型搜int size
如果这俩系数都传递空值，则返回数据库里的所有付款记录。
如果输入客户id，则只返回这个客户的付款amount;
如果两个系数都赋值了，应返回指定客户和付款方式支付的所有货款。*/

#MOSH老师答案： 
#右键项目栏新建存储过程 ,改名字,加语句，重点在WHERE条件后，要输入两个条件，因为有两个需要筛选的条件
#！！注意参数命名与表中列名的区别使用，上面两个是形参，是我们给我们要输入的实参值占的两个坑位，跟原表列名没关系 
/* 以下是手写完整代码演示
DROP PROCEDURE IF EXISTS get_payments;

DELIMITER $$
CREATE PROCEDURE get_payments
(
	client_id INT,
    payment_method_id TINYINT   #这里是付款方式id
)
BEGIN
		SELECT * FROM payments p
		WHERE 
			p.client_id = IFNULL(client_id, p.client_id) AND
            p.payment_method = IFNULL(payment_method_id, p.payment_method);  #这里是付款方式id
END$$

DELIMITER ;
*/
#调用过程 
#理论上，调用的括号内赋的值叫做实参Arguments（实际参数）
/*实参Arguments / Parameter形参的区别：
形参是占位符，或者说在过程或函数中定义的小小坑位.在这个例子中，我们定义了两个形参：客户id和付款方式id;
实参是我们提供给上面两个形参的具体值.   */
-- CALL get_payments(NULL, NULL)
-- CALL get_payments(1, NULL)
-- CALL get_payments(5, 2)


## 9.24 P74 参数验证 
# 以上学习了以SELECT数据的部分存储过程procedure，之后也可以使用procedure来插入、更新和删除数据 
/*本节课会
1.创建一个过程更新发票invoices表 ，
2. 并且作为其中的一个步骤还会学习参数验证,去确保我们的pro不会意外存储错的数据 
*/
/* 首先创建一个新的过程,名为make_payment，需要添加三个参数invoice_id(INT), payment_amount
invoice_id INT,
payment_amount DECIMAL(9,2)   #DECIMAL小数数据类型，第一个参数9表示整个数据能有多少位数，第二个参数2表示小数点后的位数 
payment_date DATE   #后面是数据类型

UPDATE invoices i
SET 
	i.payment_total = payment_amount,   #这我们只想更新两列，通过我们输入两项实参值更新原表 
    i.payment_date = payment_date
WHERE i.invoice_id = invoice_id;
*/
# 1）右键CREATE创建后输入相应代码后,apply,之后直接点击存储过程右边的小闪电，会跳出你定的三个形参况，让你输入实参 ，
# 2）因为我们这里用的是SET，相当于让表值等于我们输入的实参值 ，分别输入2,100,2019-01-01，点执行 
# 3）这时会跳出调用语句，说明已经更新完成，我们再点开INVOICES表查看

# 如果我们在调用这个过程中传递了一个负值怎么办？ 
# 答：同样会更新到表中，但这不符合表中实际的数据要求，所以我们应加上验证我们传递给存储过程的参数。 

# 如何验证我们传递给存储过程的参数？
# 答：在BEGIN后，UPDATE语句前，加上IF语句验证我们输入的实参有效性 
# 以下就是 验证存储过程的参数 代码部分
/* IF payment_amount <= 0 THEN
		SIGNAL SQLSTATE '22003'        #'22003'这是一个字符串，不是数字
			SET MESSAGE_TEXT = 'Invalid payment amount';
	END IF;
	1)SIGNAL语句来标志或触发错误,相当于Python里的except
	2)再加上一个包含错误代码的字符串常值（可搜sqlstate errors,去ibm的那个网站，找到错误类型代码;
    3)为了帮助我们更快知道调用失败的原因，可以选择发送错误信息,所以设置描述信息很有用
补充完代码后，应用apply,返回到调用的查询表，改成-100执行，输出窗口会显示错误信息。 
*/

/*当然如果代码中验证逻辑过多，这就会使得你的存储过程变得很难维护，
所以这我们不打算查看定的形参是不是空值,因为付款总计本就不允许空值,
所以尽量利用最少的验证逻辑，只保留最关键的部分。   
故应该在从用户端接受信息那会就控制数据类型，而不是到了数据库再去验证。
把参数验证作为终极备选方案,以防给那些没有在用户端输入过信息的人调用你的存储过程。*/


## P75 输出参数 
# 我们还可用参数来给调用程序返回值 
/* 创建一个新的存储过程 名未支付发票顾客，参数是client_id,语句假设只想获得所有未支付发票的计数和总数 
	SELECT COUNT(*), SUM(invoice_total)
    FROM invoices i
    WHERE i.client_id = client_id
		AND payment_total = 0;
*/# 调用程序即可得到相应答案 

#同时我们也可以通过形参数获取这些值
/*需要加几个参数
client_id INT,
OUT invoices_count INT,   #可以使用TINYINT/INT，具体根据未支付发票数量决定
OUT invoices_total DECIMAL(9,2)
默认情况下，现在存储过程中的所有这些系数都是输入参数,形参，也就是说我们只能在给pro传递值时才能使用它 
所以这我们需要给后两个参数附上OUT关键词前缀，才会使其把形参标记为输出参数,所以我们就可以从pro中获取这些值。
 加上以下修改：
    SELECT COUNT(*), SUM(invoice_total)  #意为我们读取这些数据，然后复制到下行两个输出参数
    INTO invoices_count, invoices_total  相当于给上面两个聚合函数的结果起了个“名字”
    FROM invoices i
    WHERE i.client_id = client_id
		AND payment_total = 0;
修改完代码后apply,再次执行这个pro,会蹦出三个参数框，第一个client_id是让你输入的输入参数，后两个是输出参数。 

输完client_id = 3后蹦出的结果和上面一样， 但是代码不同 
set @invoices_count = 0;   #首先定义了这两个变量，称为用户定义变量，SET将两个变量初始值设为0
set @invoices_total = 0;     available其实就是我们可用来存储单一值的对象，@符号前缀用来定义变量
call sql_invoicing.get_unpaid_invoices_for_client   #当调用这个pro时，我们需要传递这些变量
	(3, @invoices_count, @invoices_total);    第一个3就是客户id，
select @invoices_count, @invoices_total;   调用程序后，我们需要用选择语句来读取这些值，并在次显示

所以使用输出参数需要在读取数据上更复杂，尽量避免使用。
*/


## P76 变量 10.3
/* 1. 用户变量与本地变量的区别
通常我们会在调用有输出参数的存储过程时使用这些变量 ，@定义的变量，这些变量在整个会话过程中被保存， 
当用户从mysql断线时，这些变量又被清空。我们称其为 "USER or session variable" 用户或会话变量。
---USER or session variable
SET @INVOICES_COUNT = 0  用SET语句定义它们，并用@符号作为前缀。

在mysql中还有另外一种变量，叫“本地变量” —— Local variable
这些变量使我们可以在pro存储过程或者函数内被定义的，并不会在整个客户会话过程中被保存，
这些本地变量只有在我们的存储过程中才有意义.一旦我们的存储过程完成执行任务END，这些变量就被清空了。
通常我们是在pro中执行计算任务是使用这类型变量。

2. 如何在存储过程中声明并使用本地变量?
演示：
首先创建一个新的pro，叫做“get_risk_factor”
在设定一个商业规则,假设 risk_factor = invoices_total / invoices_count * 5
我们可以在过程中定义这些本地变量local variable

实操：
首先要在BEGIN语句后声明一下变量，所以用DECLARE语句声明变量，比如risk_factor,
然后规定它的数据类型DECIMAL(9,2) ；
还可以给予这个变量一个默认值DEFAULT 0， 不然默认值就成空值了
DECLARE risk_factor DECIMAL(9,2) DEFAULT 0;
DECLARE invoices_total DECIMAL(9,2);  #invoices_total/count的值我们是通过选择语句设定的，所以不需要给它设定默认值
DECLARE invoices_count INT;

选择语句设置上两个变量
SELECT COUNT(*), SUM(invoice_total)   #这里相当于读取这些聚合函数的结果，然后放进INTO上面设置的两个变量里
INTO invoices_count, invoices_total
FROM invoices;

接下来计算risk_factor
使用SET 语句来设置变量的值 
SET risk_factor = invoices_total / invoices_count * 5;

SELECT risk_factor;
*/


## P77 函数 10.3
#函数和存储过程的主要区别在于: 函数只能返回单一值,不能像pro一样返回多行多列的结果集。
/* 1. 如何创建自己的函数?
例子： 上节课的风险因素计算 ，本节会创建函数计算（每位客户）的风险因素 
收起pro项目栏，右键Functions函数项目栏，选中Create Function.
1)改名，函数名为 get_risk_factor_for_client
2)在括号内定义我们的参数，比如client_id, 类型为INT  client_id INT
	RETURN语句是函数和存储过程的主要区别,他明确了函数返回值的类型,可以是INT/integer/... 
3) 在RETURN函数后,紧跟着要设置函数属性；
	DETERMINISTIC(确定性):如果我们给予这个函数同样的一组值,它永远会返回一样的值;
    READS SQL DATA(获取SQL数据): 函数会配置SELECT语句, 用以读取一些数据;
    NODIFIES SQL DATA(修改SQL数据）：函数中有插入、更新或删除函数。
    并且也可以有多种属性，比如如果你的函数既读取又修改数据，就用2）3）
    
    回到例子，如果重复给同一个顾客id，他可能会返回不同值，因为同一个客户过不久可能又会支付其他发票，
    所以不具有确定性，故我们选择使用READS SQL DATA。

4）写上选择语句
    DECLARE risk_factor DECIMAL(9,2) DEFAULT 0;
	DECLARE invoices_total DECIMAL(9,2); 
	DECLARE invoices_count INT;

	SELECT COUNT(*), SUM(invoice_total)   
	INTO invoices_count, invoices_total
	FROM invoices i
    WHERE i.client_id = client_id;
    
    SET risk_factor = invoices_total / invoices_count * 5;

	RETURN risk_factor;

5) apply应用建立这个函数后，我们可以在选择与剧中使用这个函数，和其他mysql内置函数一样 
	SELECT 
		client_id, 
		name,
        get_risk_factor_for_client(client_id) AS risk_factor
    FROM clients
    
    有的客户风险呈现NULL空值，原因是这些客户没有发票，发票数为0,
    COUNT(*) 对应 invoices_total COUNT(*)永远大于等于0，发票数为0
    SUM(invoices_total)对应 invoices_total ,发票总额。
    如果这个客户没有任何发票，SUM聚合函数会返回空值，0除以空值 = 空值

6)使用IFNULL函数 
	RETURN IFNULL(risk_factor, 0);
    如果risk_factor是个空值NULL，我们就返回0
    
7) 将函数存储到sql文件里并放到源代码里，方便调用和调整，和VIEW，PROCEDURE一样。

8) 最后我们可以用DROP FUNCTION来删除函数
	DROP FUNCTION IF EXIST get_risk_factor_for_client;
*/


## P78 其他约定 10.3
/* 每个公司，每个人在写代码时，都有可能有自己的习惯，
   比如命名时：在函数前加fn，在存储过程加proc.的前缀， 
   有的人命名函数或pro时喜欢用驼峰式,例如 procGetRiskFactor——将首字母大写;
   或者用下划线连接。
   更改默认符时也是同样：$$或者//
   这些习惯建议入乡随俗，不要花时间argue
*/