### 窗口函数 
/* 窗口函数的定义及参数选项 
1.定义：窗口函数可以像聚合函数一样对一组数据进行分析并返回结果，二者的不同之处在于，
窗口函数不是将一组数据汇总成单个结果，而是为每一行数据都返回一个结果。
主要解决产品的累计销量统计、分类排名、同比/环比分析等。
这些功能通常很难通过聚合函数和分组操作来实现。

USE sql_hr;
SELECT SUM(salary)
FROM employees e;   

USE sql_hr;
SELECT employee_id,SUM(salary) OVER()
FROM employees e;

USE sql_hr;
SELECT employee_id, salary, office_id,
	SUM(salary) OVER (PARTITION BY office_id) AS "部门合计"
FROM employees;
 
USE sql_hr;
SELECT employee_id, office_id, salary, 
	RANK() OVER (
    PARTITION BY office_id
    ORDER BY salary DESC
    ) AS "部门排名"
FROM employees;
 
 
USE sql_hr;
SELECT employee_id, office_id, salary, 
	SUM(salary) OVER (
    PARTITION BY office_id
    ORDER BY salary DESC
    ) AS "部门合计"
FROM employees;
*/
##techTFQ印度口音-窗口函数教程
/* 
理解窗口函数最佳方法就是先遍历一个聚合函数。 
这里我们用sql_hr内的employees表作为演示
(为了应和教程，主要用employee_id, first_name, office_id, salary这些行）

查询员工的最高薪水
SELECT MAX(salary) FROM employees;
查询每个办公室内的员工最高薪水 
SELECT office_id, MAX(salary) FROM employees GROUP BY office_id;
因为除聚合函数外，所有出现在 SELECT 中的列必须在 GROUP BY 中!!!
所以如果还想显示e表的其他信息，除了可使用with语句，最好的方法就是窗口函数。a
WITH ... AS (...) 是 SQL 中的 Common Table Expression (CTE)，也称为公共表表达式。


*/
/*
#提取聚合列以及表内其他列的详细信息
SELECT 
	e.*,
    MAX(salary) OVER () AS max_salary  # 这里max_salary使用的数值范围是salary列的所有行
FROM employees e;

OVER子句的存在使之不会将MAX视为聚合函数，而是将其视为窗口函数；
OVER一般是用于指定你需要创建窗口函数的数据范围，如果像上面什么都没指定， 
SQL会将所有记录当做窗口数据范围。对于这个特定的窗口，使用这个特定的函数。 

# 现在假设我们想提取每个部门对应的最高工资 
SELECT *,
	MAX(salary) OVER (
    PARTITION BY office_id) AS "部门最高薪"
FROM employees
针对在office_id这列中每一个不同的值，都将创建属于它的一个窗口，然后将这个函数 MAX(salary)应用到每个窗口 

同样的可以使用其他查询语句中的聚合函数，例如avg, count, sum等等。
除此之外，也有一些sql专门的窗口函数ROW_NUMBER()、

1.ROW_NUMBER()
 #为表中的每条记录分配一个唯一值，（类似于排序）
 SELECT *,
	ROW_NUMBER() OVER() AS rn
 FROM employees 

 由于这里OVER子句内我们没有限定范围，所以sql会将此表内的所有数据视为一个窗口， 
 所以这里有20条数据，rn也排序到20。
 
 #假设不同的部门分配一下号码 
  SELECT *,
	ROW_NUMBER() OVER(
    PARTITION BY office_id) AS rn
 FROM employees
 对于每个office_id列中的不同值，都会分别创建一个窗口，应用RN函数，故每个窗口， 
 根据记录数排序分配一个唯一值。 
 
#这个函数的用处/使用场景：比如想获取每个部门的员工id前两名员工
 (假设员工id大小意味着员工入职的时间长短，越小越早入职，时间越长），
SELECT *,
	ROW_NUMBER() OVER(
    PARTITION BY office_id
    ORDER BY employee_id) AS rn2
 FROM employees
 
 由于我这使用的数据源一开始员工id就是按顺序从小到大排的，所以这里我可能没有区别。 
 假设这个按办公室id分组完后，员工id里的顺序不对，而这里我们需要它按照员工id从小到大排序，
 所以我们就要使用ORDER BY，
 又因为我们的要求是获取每个部门员工id前两名的员工，所以在上面代码的基础上
 可以使用子查询
 
 SELECT * FROM(
 SELECT employee_id, office_id, salary,
	ROW_NUMBER() OVER(
    PARTITION BY office_id
    ORDER BY employee_id) AS rn
 FROM employees) AS X 
 WHERE X.rn < 3;

 2.RANK()函数
 假设你想要获取每个部门薪金最高的前三名员工

 USE sql_hr;
 SELECT * FROM(
 SELECT employee_id, first_name,
	RANK() OVER(
    PARTITION BY office_id
    ORDER BY salary DESC
    ) AS ra
FROM employees) AS X
WHERE X.ra < 4

这里需要注意的是相同排名，因为如果salary相同，sql给的rank排名也是相同的，
比如前两位薪水都是一样的高，ra都为1，那么第三位员工它的ra就是3（本数据源不存在这个问题）
但是因此需要根据题目要求注意主查询的WHERE条件书写。

 3.DENSE_RANK()函数
	与RANK函数的唯一区别在如果有重复值，它不会跳过(重复值的个数）的值；
    比如前两位薪水都是一样的高，ra都为1，那么第三位员工它的D_ra还是2

SELECT employee_id, office_id,first_name,
	RANK() OVER(PARTITION BY office_id ORDER BY salary DESC) AS ra,
    DENSE_RANK() OVER(PARTITION BY office_id ORDER BY salary DESC) AS D_ra
FROM employees

##为什么我们不对上面这几个函数中传递任何值，()括号内都是空的，
因为rank,dense_rank,row_number都只是为每条记录都分配一个值的函数。

4. LEAD() & LAG()函数
	假设你想要检查每个办公室内当前的员工工资是否高/低于前任员工，我们可以使用lag滞后函数做到。
1)LAG()滞后函数

SELECT employee_id, first_name,salary,
	LAG(salary) OVER(
    PARTITION BY office_id
    ORDER BY employee_id
    ) AS prev_emp_salary
FROM employees

每组会从第二条记录开始返回上一条的工资;
LAG(列名称)默认情况下，始终返回查询上一条对应列的记录
LAG(column_name, offset, default_value)
column_name:指定要比较或访问的列; 
offset: 表示要向前偏移的行数。
default_value: 如果指定的偏移超出了范围（即不存在第 offset 行），则返回这个默认值。如果省略就是返回null

LAG(列名称, 2, 0) 2代表查找返回当前行前2行的数据, 0代表如果没有上一条记录,则默认返回0而不是null.

SELECT employee_id, first_name,salary,
	LAG(salary, 2, 0) OVER(
    PARTITION BY office_id
    ORDER BY employee_id
    ) AS prev_emp_salary
FROM employees

1)Lead()
	与上面LAG()函数用法相同，不同的是返回当前记录‘之后’的行数据

SELECT employee_id, office_id, salary,
	LAG(salary) OVER(PARTITION BY office_id ORDER BY employee_id) AS prev_emp_salary,
	LEAD(salary) OVER(PARTITION BY office_id ORDER BY employee_id) AS next_emp_salary
FROM employees

举例: 查询返回 如果现任员工工资高于/低于/相等前任员工工资,显示高于/低于/相等

SELECT employee_id, first_name,salary,
	CASE WHEN(salary > LAG(salary) OVER(PARTITION BY office_id ORDER BY employee_id)) THEN '高于'
        WHEN(salary = LAG(salary) OVER(PARTITION BY office_id ORDER BY employee_id)) THEN '等于'
        WHEN(salary < LAG(salary) OVER(PARTITION BY office_id ORDER BY employee_id)) THEN '低于'
    END AS compa
FROM employees
*/
SELECT employee_id, office_id,salary,
	LAG(salary) OVER(PARTITION BY office_id ORDER BY employee_id) AS prev_emp_salary,
	CASE WHEN(e.salary > LAG(salary) OVER(PARTITION BY office_id ORDER BY employee_id)) THEN "高于"
		WHEN(e.salary = LAG(salary) OVER(PARTITION BY office_id ORDER BY employee_id)) THEN "等于"
        WHEN(e.salary < LAG(salary) OVER(PARTITION BY office_id ORDER BY employee_id)) THEN "低于"
    END AS sal_range
FROM employees e








