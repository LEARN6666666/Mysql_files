/* 8weekschanlleng01
1.每位顾客在餐厅消费的总金额是多少？

SELECT customer_id, SUM(price) AS total
FROM sales s
LEFT JOIN  menu m
	ON 	s.product_id = m.product_id
GROUP BY s.customer_id

#2.每位顾客光顾餐厅多少天？
SELECT COUNT(DISTINCT(order_date)) AS DAYS
FROM sales
GROUP BY customer_id

#3.每位顾客从菜单中购买的第一道菜是什么？
SELECT DISTINCT(s.customer_id), product_name AS first_dish
FROM sales s
LEFT JOIN  menu m
	ON 	s.product_id = m.product_id
WHERE s.order_date IN (SELECT MIN(order_date) FROM sales GROUP BY s.customer_id) ;

#或者用窗口函数DENSE_RANK

#4.菜单上购买最多的菜品是什么，所有顾客购买了多少次？
SELECT product_name, COUNT(s.product_id) AS total_sale
FROM sales s
LEFT JOIN  menu m
	ON 	s.product_id = m.product_id
GROUP BY s.product_id, product_name
ORDER BY COUNT(s.product_id) DESC
LIMIT 1

#5.哪件商品最受每位买家欢迎？
#注意：如果数据集中出现购买次数相同的商品，这个查询会返回所有最受欢迎的商品（并列第一）。
#如果需要随机选择一件商品，可以使用 ROW_NUMBER() 替代 RANK()。
SELECT customer_id, product_id AS best_sale
FROM (SELECT customer_id, product_id ,
	ROW_NUMBER()OVER(PARTITION BY customer_id ORDER BY COUNT(product_id) DESC) AS ra 
    FROM sales
    GROUP BY customer_id, product_id) AS P1
WHERE P1.ra = 1

#也可以用CTE表达式--对于每位顾客的个人的最爱产品排名查询 
WITH ranked_sales AS (
  SELECT 
    customer_id, 
    product_id, 
    COUNT(*) AS product_count,
    RANK() OVER (PARTITION BY customer_id ORDER BY COUNT(*) DESC) AS ra
  FROM sales
  GROUP BY customer_id, product_id
)
SELECT customer_id, product_id AS best_sale
FROM ranked_sales
WHERE ra = 1;

#6.客户成为会员后首先购买了哪件商品？
USE dannys_diner;
SELECT customer_id, product_id
FROM(SELECT s.customer_id, s.product_id,
	row_number()OVER(partition by s.customer_id ORDER BY order_date) AS rn
FROM sales s
LEFT JOIN members m
	ON s.customer_id = m.customer_id
WHERE s.order_date >= m.join_date
) AS P1
WHERE P1.rn = 1

#CTE表达式其实就是将上面子连接的部分单独写出来，下面主查询FROM CTE
WITH join_mem_aft AS(
	SELECT s.customer_id, s.product_id,
		row_number()OVER(partition by s.customer_id ORDER BY order_date) AS rn
	FROM sales s
	LEFT JOIN members m
		ON s.customer_id = m.customer_id
	WHERE s.order_date >= m.join_date
)

SELECT customer_id, product_id
FROM join_mem_aft
WHERE rn = 1;

#如果要的是产品名字，不是id，就需要再凭借使用menu表，这时候使用CTE效率更高，在主查询中连接menu表 
SELECT customer_id, product_id
FROM join_mem_aft j
JOIN menu me
	ON j.product_id = me.product_id
WHERE rn = 1;


#7.在客户成为会员之前购买了哪件商品？(补充最后购买的一件商品）
SELECT customer_id, product_id
FROM(SELECT s.customer_id, s.product_id,
	row_number()OVER(partition by s.customer_id ORDER BY order_date) AS rn
FROM sales s
LEFT JOIN members m
	ON s.customer_id = m.customer_id
WHERE s.order_date < m.join_date
) AS P1
WHERE P1.rn = 1


#8.每位会员在成为会员之前的总物品和消费金额是多少？
WITH join_mem_bef AS(  #成为会员之前的CTE表达式
	SELECT s.customer_id, s.product_id,
		row_number()OVER(partition by s.customer_id ORDER BY order_date) AS rn
	FROM sales s
	LEFT JOIN members m
		ON s.customer_id = m.customer_id
	WHERE s.order_date < m.join_date
)

SELECT 
	customer_id, 
    COUNT(jmb.product_id) AS total_item, 
    SUM(me.price) AS total_cost
FROM join_mem_bef jmb
LEFT JOIN menu me
	ON jmb.product_id = me.product_id
GROUP BY customer_id;




#9.如果每消费 1 美元等于 10 分，而寿司有 2 倍的积分乘数 - 每个顾客将拥有多少积分？
WITH points_count AS(
	SELECT s.customer_id, s.product_id,
    CASE WHEN product_name = 'sushi' THEN price * 20 ELSE price * 10 END AS points
    FROM sales s
    LEFT JOIN menu mn
		ON mn.product_id = s.product_id
)

SELECT customer_id, SUM(points) AS total_points
FROM points_count
GROUP BY customer_id;



*/	

/*10.在顾客加入计划后的第一周（包括加入日期），他们在所有商品上均可获得 2 倍积分，
而不仅仅是寿司 - 顾客 A 和 B 在 1 月底拥有多少积分？*/
#会员第一周内的两倍积分，再加上其他时期的积分 (这里计算的是成为会员后到一月底的积分，成为会员前没有积分
WITH point_count AS (
	SELECT s.customer_id,s.product_id, s.order_date, mn.price, m.join_date, 
		CASE WHEN order_date BETWEEN join_date AND DATE_ADD(join_date, INTERVAL 6 DAY) THEN price*20
             WHEN order_date NOT BETWEEN join_date AND DATE_ADD(join_date, INTERVAL 6 DAY) AND 
             product_name = 'sushi' THEN price * 20
             ELSE price * 10
             END AS points2
	FROM sales s
    LEFT JOIN members m
		ON s.customer_id = m.customer_id
	LEFT JOIN menu mn
		ON s.product_id = mn.product_id
	)

SELECT customer_id, SUM(points2) AS total_points
FROM point_count 
WHERE order_date < '2021-02-01' AND order_date >= join_date
GROUP BY customer_id
HAVING customer_id = 'A' OR customer_id = 'B';






