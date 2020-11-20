SELECT 
	t.user_id,
	CASE
		WHEN t.d<=30 THEN 3
		WHEN t.d>30 AND t.d<=90 THEN 2
		WHEN t.d>90 THEN 1 END AS R,
	CASE
		WHEN t.n>=5 THEN 3
		WHEN t.n>=3 AND t.n<5 THEN 2
		WHEN t.n<3 THEN 1 END AS F,
	CASE
		WHEN t.s>=20 THEN 3
		WHEN t.s>8 AND t.s<20 THEN 2
		WHEN t.n<=8 THEN 1 END AS M
FROM
	(SELECT 
		user_id, 
		COUNT(id_o) AS n, 
		SUM(price) AS s, 
		julianday('2018-01-01') - julianday(max( substr(o_date, 7) || "-" || substr(o_date,4,2)  || "-" || substr(o_date, 1,2))) AS d 
	FROM orders GROUP BY user_id) AS t;