DROP TABLE IF EXISTS new_data ;

/* 
1. Определяем критерии для каждой буквы R, F, M (т.е. к примеру, R – 3 для клиентов, 
которые покупали <= 30 дней от последней даты в базе, R – 2 для клиентов, которые покупали > 30 
и менее 60 дней от последней даты в базе и т.д.
2. Для каждого пользователя получаем набор из 3 цифр (от 111 до 333, где 333 – самые классные пользователи)
*/
CREATE TABLE new_data AS
SELECT 
	t.user_id, t.n, t.s,
	CASE
		WHEN t.d<=30 THEN 3
		WHEN t.d>30 AND t.d<=90 THEN 2
		WHEN t.d>90 THEN 1 END||
	CASE
		WHEN t.n>=5 THEN 3
		WHEN t.n>=3 AND t.n<5 THEN 2
		WHEN t.n<3 THEN 1 END ||
	CASE
		WHEN t.s>=20 THEN 3
		WHEN t.s>8 AND t.s<20 THEN 2
		WHEN t.n<=8 THEN 1 END AS RFM
FROM
	(SELECT 
		user_id, 
		COUNT(id_o) AS n, 
		SUM(price) AS s, 
		julianday('2018-01-01') - julianday(max( substr(o_date, 7) || "-" || substr(o_date,4,2)  || "-" || substr(o_date, 1,2))) AS d 
	FROM orders GROUP BY user_id) AS t
ORDER BY RFM DESC;
	
/*
3. Вводим группировку, к примеру, 
333 и 233 – это Vip, 
1XX – это Lost, 
остальные Regular
*/
DROP TABLE IF EXISTS grad;
CREATE TABLE grad AS
SELECT new_data.user_id, new_data.n, new_data.s, 
		CASE
			WHEN CAST(new_data.RFM AS INTEGER) = 333 OR CAST(new_data.RFM AS INTEGER) = 233 THEN 'Vip'
			WHEN CAST(new_data.RFM AS Integer) < 133 THEN 'Lost'
			ELSE 'Regular' END AS gr
FROM new_data;

/*
Для каждой группы из п. 3 находим кол-во пользователей, 
кот. попали в них и % товарооборота, 
которое они сделали на эти 2 года.
*/
SELECT gr, count(user_id) AS num, sum(s) AS val, sum(s) / (SELECT sum(s) FROM grad) AS percent FROM grad GROUP BY gr;

