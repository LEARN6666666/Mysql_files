## p79 第十章 触发器TRIGGER 
/* 1. TRIGGER触发器：是指在插入，更新和删除语句前后自动执行的一堆SQL代码。
	通常我们使用它是为了增强数据一致性。
    
    例如在sql_store数据库中，一张发票invoice可以对应好几笔付款payment，
    在invoices表中的payment_total这列的值就是等于这章发票所有付款的总和，
    所以每当我们往payments付款表中录入一条新纪录，我们要确认invoices发票表里的payment_total更新了。 
    这种时候就可以使用触发器了。

DELIMITER $$   #首先我们需要修改默认分隔符 

2. 取触发器名字时可借鉴：先是明确表名，接着输入'after'/'before'表示触发器是在语句前/后触发，最后写上引爆触发器的语句类型。
CREATE TRIGGER payment_afer_insert  #意为这个触发器关联到payments表，并且会在我们插入insert一条新纪录以后引燃 
	AFTER INSERT ON payments        #明确语句告诉MYSQL我们想让触发器在 INSERT/UPDATE/DROP 语句前/后触发 
    FOR EACH ROW           #意为作用于每一个受影响的行，比如我们插入5行，每一行都会触发一次TRIGGER
 
BEGIN
	#主体部分我们可以写任意sql代码修改数据，来增强一致性,我们可以直接写代码或者调用pro 
    NEW关键字会返回我们刚刚插入的行, NEW.通过后面的.获得单独属性
    OLD 关键词在更新/删除行的时候很有用，会赶回更新前的行以及数值
    UPDATE invoices 
    SET payment_total = payment_total + NEW.amount
END $$

DELIMITER ;   */

#演示代码
# 写完代码后，我们可以查看payments表下的columns，每当我们往列里插新纪录，通过NEW.amount就可以获取新付款额 
# 这个触发器我们可以修改任何表中的数据，除了这个触发器所在表payments，不然就是无限循环了，
/*
DELIMITER $$ 

CREATE TRIGGER payment_afer_insert
	AFTER INSERT ON payments 
    FOR EACH ROW     
BEGIN
    UPDATE invoices 
    SET payment_total = payment_total + NEW.amount
    WHERE invoice_id = NEW.invoice_id;
END $$

DELIMITER ;
*/

/*
1)执行以上代码后，查看invoices表，假设给3号发票做一个十美元的payment，回来看invoices表的payment_total有什么变化？ 
2)打开一个新查询窗口，输入以下代码，插入新数据，赋予新数据值时，可以打开payments的columns对应着写
INSERT INTO payments
VALUES (DEFAULT, 5, 3, '2019-01-01', 10, 1)
DEFAULT意味着mysql给我们生成一个默认id，执行后返回查看INVOICES表中3号发票的payment_total
*/

##练习：创建一个触发器,在我们删除付款payment数据时触发,它会减少付款总额
/* 1)创建触发器
DELIMITER $$ 

CREATE TRIGGER payment_afer_delete
	AFTER DELETE ON payments 
    FOR EACH ROW     
BEGIN
    UPDATE invoices 
    SET payment_total = payment_total - OLD.amount
    WHERE invoice_id = OLD.invoice_id;
END $$

DELIMITER ;

2）验证触发器环节,我们就用上面增加的3号发票，再把它删除
DELETE 
FROM payments
WHERE payment_id = 12 

3）刷新invoices表，查看是否触发
*/


## P80 查看触发器 10.4

-- SHOW TRIGGERS; #查看所有当前数据库的触发器

# 我们也可以过滤返回信息，如果你只想查看有关payments表的触发器,可以用LIKE
-- SHOW TRIGGERS LIKE 'payments%'  #以payments开头的表达方式


## P81 删除触发器 10.4

-- DROP TRIGGER IF EXISTS payments_after_insert; 
/*同样我们应该把删除与创建语句放在同一个脚本文件中,并录入一个源代码库中,
这样整个团队都可以用,并且可以看到历史数据库修改记录,代码如下。
DELIMITER $$ 

DROP TRIGGER IF EXISTS payments_after_insert;

CREATE TRIGGER payment_after_insert
	AFTER INSERT ON payments 
    FOR EACH ROW     
BEGIN
    UPDATE invoices 
    SET payment_total = payment_total + NEW.amount
    WHERE invoice_id = NEW.invoice_id;
END $$

DELIMITER ;
保存到以上代码到触发器专属文件中
*/  


## P82 使用触发器进行审计  10.4
/* 上面说了触发器可以增强表中数据一致性,
触发器的另一个常见用途是为了审计的目的,记录对数据库的修改.用触发器去记录变更。
例如:当一个人增加或删除某条记录,我们可以把这个操作记录下来,以便后面查询
创建payments_audit这张新标的源代码在课程文件里——crate-payments-table

1. 向payments插入一条数据的触发器审计记录

1)执行该代码,创建了一张新表payment_audit
action_type意为操作类型 INSERT/UPDATE/DROP; action_date操作日期

2)返回触发器查询，每当我们更新一条invoices数据，就给审计表payments_audit加一条数据,依此修改触发器代码 
为什么一直报错:要在本查询窗口执行这个程序！！

DELIMITER $$ 

DROP TRIGGER IF EXISTS payment_after_insert;

CREATE TRIGGER payment_after_insert
	AFTER INSERT ON payments 
    FOR EACH ROW     
BEGIN
    UPDATE invoices 
    SET payment_total = payment_total + NEW.amount
    WHERE invoice_id = NEW.invoice_id;
    
    INSERT INTO payments_audit
    VALUES (NEW.client_id, NEW.date, NEW.amount, 'INSERT', NOW());
END $$

DELIMITER ;

同样的操作作用于上练习中另一个触发器payment_after_delete,复制这两行,
将操作类型改成DELETE，NEW改成OLD
    INSERT INTO payments_audit
    VALUES (OLD.client_id, OLD.date, OLD.amount, 'DELETE', NOW());
    
3）验证环节：向payments表中插入一条新的付款记录，
INSERT INTO payments
VALUES (DEFAULT, 5, 3, '2019-01-01', 10, 1)
执行并查看审计表 
*/

/*
2. 向payments更新一条数据后的触发器审计记录
1）先删除上面审计表结果的数据条 
DELETE FROM payments
WHERE payment_id = 15

在这之前，得先执行新的payment_after_delete的触发表
DELIMITER $$ 

DROP TRIGGER IF EXISTS payment_after_delete;

CREATE TRIGGER payment_after_delete
	AFTER DELETE ON payments 
    FOR EACH ROW     
BEGIN
    UPDATE invoices 
    SET payment_total = payment_total - OLD.amount
    WHERE invoice_id = OLD.invoice_id;
    
	INSERT INTO payments_audit
    VALUES (OLD.client_id, OLD.date, OLD.amount, 'DELETE', NOW());
END $$

DELIMITER ;

2)回到审计表刷新结果,发现有以上插入和删除两条记录。 

现实中可能需要给多张表记录变更，不建议给每张表分别建审计表，可以建立一个总架构来记录变更。
之后的课程会讲到怎样设计数据库，那时会介绍如何创建一个总审计表。
*/


## P83 事件 EVENTS 10.4
/*事件是根据计划执行的任务或一堆sql代码，可以执行一次，也可以按照某种规律执行，例如每天早上/每月十号等 
  所以可以使用Events进行自动化数据库维护任务，
  比如删除过期数据，或者把数据从一张表复制到存档表，又或者定期汇总数据生成报告。
  
  1.在我们设计一个事件前，首先打开MYSQL事件调度器，是一个后台程序，
  SHOW VARIABLES ;  
  可以看到mysql所有的系统变量,我们需要找到事件管理器变量,用到LIKE
  SHOW VARIABLES LIKE 'event%'; 
  
  状态如果是OFF,可以通过SET语句把它打开，或者你想节省资源，也可以把它关掉OFF
  SET GLOBAL event_scheduler = ON
  
  2. 如何创建一个事件event?
  1)首先修改默认分隔符 
  
DELIMITER $$

2）每年删除过期审计行,开头标明事件触发频率,年度/月度/星期
执行一次/定期执行，执行一次:用AT关键字; 定期执行：用EVERY关键字，并添加区间信息。

CREATE EVENT yearly_delete_stale_audit_rows   
ON SCHEDULE
	-- AT '2019-05-01'
    EVERY 1 YEAR STARTS '2019-01-01' ENDS '2029-01-01'
DO	BEGIN
	DELETE FROM payments_sudit
	WHERE action_date < NOW() - INTERVAL 1 YEAR;   
    
3）INTERVAL 1 YEAR：表示一个时间间隔，具体是1年。
    #或者使用DATEADD函数/DATESUB函数
    DATEADD(NOW(), INTERVAL -1 YEAR)
    DATESUB(NOW(), INTERVAL 1 YEAR)
    
END $$

DELIMITER ;
以上代码可以删除所有超过一年的审计记录， 
  */
  /*执行代码
DELIMITER $$

CREATE EVENT yearly_delete_stale_audit_rows   
ON SCHEDULE
	-- AT '2019-05-01'
    EVERY 1 YEAR STARTS '2019-01-01' ENDS '2029-01-01'
DO	BEGIN
	DELETE FROM payments_audit
	WHERE action_date < NOW() - INTERVAL 1 YEAR; 
END $$

DELIMITER ;
*/


## P84 查看、删除和更改事件 10.4
/*
1.查看当前数据库的事件，我们使用SHOW EVENTS语句
SHOW EVENTS;
好的命名可以帮助更快筛选出事件，比如想找到年度执行的时间，用LIKE查询
SHOW EVENTS LIKE 'yearly%';

2.删除时间,用DROP EVENT语句
DROP EVENT IF EXISTS yearly_delete_stale_audit_rows;

3.修改事件,而不用删除再重建它ALTER EVENT,语法跟CREATE EVENT 一样

1)修改事件代码
DELIMITER $$

ALTER EVENT yearly_delete_stale_audit_rows   
ON SCHEDULE
	# 修改这部分代码
    EVERY 1 YEAR STARTS '2019-01-01' ENDS '2029-01-01'
DO	BEGIN
	#或者修改这部分代码 
	DELETE FROM payments_audit
	WHERE action_date < NOW() - INTERVAL 1 YEAR; 
END $$

DELIMITER ;

2)暂时启用或者禁用一个事件 
ALTER EVENT yearly_delete_stale_audit_rows DISABLE; #暂时禁用事件
ALTER EVENT yearly_delete_stale_audit_rows ENABLE;  #启用事件
*/


