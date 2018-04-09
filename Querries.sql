/*------------------------------------------------------------------------------------------------*/
/*RESTAURANTS AND MENUS QUERRIES [FINISHED] */
/*------------------------------------------------------------------------------------------------*/
/* Querry A: Change '00001' to the corisponding restaurant ID. Maybe update with a JOIN or UNION?*/
SELECT DISTINCT * 
FROM RESTAURANT R, LOCATION L 
WHERE R.RESTAURANT_ID = '00001' AND L.RESTAURANT_ID=R.RESTAURANT_ID;

/* Querry B: Change '00001' to the corisponding restaurant ID*/
SELECT M.ITEM_NAME, M.PRICE 
FROM MENUITEM M, RESTAURANT R 
WHERE R.RESTAURANT_ID = '00004' AND M.RESTAURANT_ID = R.RESTAURANT_ID
GROUP BY M.ITEM_TYPE, M.ITEM_NAME, M.PRICE;

/* Querry C: Change 'Casual Dining' to the user data.*/
SELECT L.MANAGER_NAME, L.FIRST_OPEN_DATE 
FROM LOCATION L, RESTAURANT R 
WHERE R.TYPE LIKE '%Casual Dining%' AND L.RESTAURANT_ID = R.RESTAURANT_ID;

/* Querry D: Change '00001' to the corisponding restaurant ID*/
SELECT M.ITEM_NAME AS DISH, R.NAME AS RESTAURANT, L.MANAGER_NAME AS MANAGER, L.HOUR_OPEN, R.URL 
FROM MENUITEM M, RESTAURANT R, LOCATION L
WHERE M.RESTAURANT_ID = R.RESTAURANT_ID AND R.RESTAURANT_ID = '00001' AND L.RESTAURANT_ID = R.RESTAURANT_ID AND M.PRICE = 
				(SELECT MAX(M.PRICE)
                 FROM MENUITEM M, RESTAURANT R
                 WHERE R.RESTAURANT_ID = '00001' AND M.RESTAURANT_ID = R.RESTAURANT_ID);

/* Querry E: */
SELECT AVG(M.PRICE) AS AVERAGE_PRICE, R.TYPE AS RESTAURANT_TYPE, M.ITEM_TYPE
FROM MENUITEM M, RESTAURANT R
GROUP BY R.TYPE, M.ITEM_TYPE;

/*------------------------------------------------------------------------------------------------*/
/*RATINGS OF RESTAURANTS QUERRIES [STUCK]*/
/*------------------------------------------------------------------------------------------------*/
/* Querry F: This one doesn't quite work... it's close but idk what's wrong...*/
SELECT DISTINCT RR.USER_ID, RS.NAME, AVG((R.FOOD + R.MOOD + R.STAFF + R.PRICE)/4) as AVG_RATING, COUNT(R.*)
FROM RATING R, RESTAURANT RS, Rater RR 
WHERE R.RESTAURANT_ID = RS.RESTAURANT_ID AND R.USER_ID = RR.USER_ID
GROUP BY RS.NAME, RR.USER_ID 
ORDER BY RS.NAME, AVG_RATING;

/* Querry G: [GOOD ENOUGH]*/
Select RS.NAME, RS.TYPE, L.PHONE_NUMBER 
FROM RESTAURANT RS, LOCATION L 
WHERE NOT EXISTS
(SELECT * 
FROM RATING R 
WHERE date_part('year',R.ORDER_DATE) = 2015 AND date_part('month',R.ORDER_DATE) = 01 AND R.RESTAURANT_ID = RS.RESTAURANT_ID) AND RS.RESTAURANT_ID = L.RESTAURANT_ID 
ORDER BY RS.NAME; 

/* Querry H: [GOOD ENOUGH]*/
Select RS.NAME, L.FIRST_OPEN_DATE 
FROM RESTAURANT RS, LOCATION L 
WHERE RS.RESTAURANT_ID IN 
(SELECT R.RESTAURANT_ID 
FROM RATING R 
WHERE R.STAFF < ANY
(Select R2.STAFF 
FROM RATING R2 
WHERE R2.USER_ID = '00031')) AND RS.RESTAURANT_ID = L.RESTAURANT_ID;

/* Querry I: Asks for 1, but because 5 is the max food rating multiple restaurants can have the highest food ratings*/
Select RS.NAME, RR.NAME 
FROM RESTAURANT RS, RATER RR 
WHERE RS.RESTAURANT_ID IN 
(SELECT R.RESTAURANT_ID 
FROM RATING R 
WHERE R.RESTAURANT_ID IN 
(SELECT RS1.RESTAURANT_ID 
FROM RESTAURANT RS1 
WHERE RS1.TYPE = 'Casual Dining') AND R.FOOD >= All
(SELECT R2.FOOD 
FROM RATING R2 
WHERE R2.RESTAURANT_ID IN 
(SELECT RS2.RESTAURANT_ID 
FROM RESTAURANT RS2 
WHERE RS2.TYPE = 'Casual Dining')) AND R.USER_ID = RR.USER_ID);

/* Querry J: Might take a bit of work?*/


/*------------------------------------------------------------------------------------------------*/
/*RATERS AND THEIR RATINGS QUERRIES [IN-PROGRESS]*/
/*------------------------------------------------------------------------------------------------*/
/* Querry K: COMPLETED */
SELECT (R.FOOD + R.MOOD) AS TOTAL_RATING, RR.NAME AS USERNAME, RR.JOINDATE, RR.REPUTATION, RS.NAME AS RESTAURANT, R.ORDER_DATE
FROM RATING R, RATER RR, RESTAURANT RS
WHERE RR.USER_ID = R.USER_ID AND RS.RESTAURANT_ID = R.RESTAURANT_ID AND (R.FOOD + R.MOOD) = (SELECT MAX(R.FOOD + R.MOOD) FROM RATING R);

/* Querry L: Is this one actually just K but simpler?*/
SELECT (R.FOOD + R.MOOD) AS TOTAL_RATING, RR.NAME AS USERNAME, RR.REPUTATION, RS.NAME AS RESTAURANT, R.ORDER_DATE
FROM RATING R, RATER RR, RESTAURANT RS
WHERE RR.USER_ID = R.USER_ID AND RS.RESTAURANT_ID = R.RESTAURANT_ID AND (R.FOOD + R.MOOD) = (SELECT MAX(R.FOOD + R.MOOD) FROM RATING R);

/* Querry M: [NOT FINISHED]*/
SELECT RR.NAME, RR.REPUTATION, R.COMMENTS 
FROM RATING R, RATER RR 
WHERE RR.USER_ID IN 
(SELECT RR1.USER_ID 
FROM RATER RR1 
WHERE(SELECT COUNT(*) 
FROM RATING R2 
WHERE R2.USER_ID = RR1.USER_ID AND R2.RESTAURANT_ID IN 
(SELECT RS.RESTAURANT_ID 
FROM RESTAURANT RS 
WHERE RS.NAME ='The Works')) >=  All(SELECT COUNT(*) 
FROM RATING R3 
WHERE R3.RESTAURANT_ID IN 
(SELECT RS.RESTAURANT_ID 
FROM RESTAURANT RS 
WHERE RS.NAME ='The Works') 
GROUP BY R3.USER_ID)) AND R.USER_ID = RR.USER_ID AND R.RESTAURANT_ID IN 
(SELECT RS.RESTAURANT_ID 
FROM RESTAURANT RS 
WHERE RS.NAME ='The Works');

/* Querry N*/ 
/*OPTION N.1: FINDS THE RATINGS UNDER THE AVERAGE OF JOHN'S RATINGS*/
SELECT DISTINCT RR.NAME, RR.EMAIL, RS.NAME
FROM RATING R, RATER RR, RESTAURANT RS
WHERE RR.USER_ID = R.USER_ID AND RS.RESTAURANT_ID = R.RESTAURANT_ID AND (R.FOOD + R.MOOD + R.STAFF + R.PRICE) < 
(SELECT AVG(R.FOOD + R.MOOD + R.STAFF + R.PRICE) 
FROM RATING R, RATER RR
WHERE RR.NAME = 'John' AND RS.RESTAURANT_ID = R.RESTAURANT_ID)
ORDER BY RS.NAME;

/*OPTION N.2: FINDS THE RATINGS UNDER THE John's FOR THE SPECIFIED RESTAURANT*/
SELECT DISTINCT RR.NAME, RR.EMAIL, RS.NAME
FROM RATING R, RATER RR, RESTAURANT RS
WHERE RR.USER_ID = R.USER_ID AND RS.RESTAURANT_ID = R.RESTAURANT_ID AND (R.FOOD + R.MOOD + R.STAFF + R.PRICE) < 
(SELECT (R.FOOD + R.MOOD + R.STAFF + R.PRICE) 
FROM RATING R, RATER RR, RESTAURANT RS
WHERE RR.NAME = 'John' AND RR.USER_ID = R.USER_ID AND RS.RESTAURANT_ID = R.RESTAURANT_ID AND RS.RESTAURANT_ID = '00002')
ORDER BY RS.NAME;

/*OPTION N.3: I remembered about the ANY function*/
SELECT RR.NAME, RR.EMAIL 
FROM RATER RR 
WHERE RR.USER_ID IN 
(SELECT R.USER_ID 
FROM RATING R 
WHERE(R.PRICE + R.FOOD + R.MOOD + R.STAFF) < ANY
(SELECT (R2.PRICE + R2.MOOD + R2.FOOD + R2.STAFF) 
FROM RATING R2 
WHERE R2.USER_ID IN 
(SELECT RR1.USER_ID 
FROM RATER RR1 
WHERE RR1.NAME = 'John')));

/* Querry O: Good enough*/
SELECT RR.NAME, RR.TYPE, RR.EMAIL
FROM RATING R, RATER RR, RESTAURANT RS
WHERE (SELECT ((MAX(R.FOOD + R.MOOD + R.STAFF + R.PRICE))-MIN(R.FOOD + R.MOOD + R.STAFF + R.PRICE))
FROM RATING R, RATER RR);
SELECT RR.NAME AS username, RR.TYPE, RR.EMAIL, RS.NAME AS restaurant, R.FOOD, R.PRICE, R.MOOD, R.STAFF 
FROM RATER RR, RATING R, RESTAURANT RS 
WHERE RR.USER_ID IN 
(SELECT RR1.USER_ID 
FROM RATER RR1 
GROUP BY RR1.USER_ID
HAVING (SELECT MAX(stddev) 
FROM(SELECT stddev(R2.MOOD + R2.STAFF + R2.PRICE + R2.FOOD) as stddev 
FROM RATING R2 
WHERE R2.USER_ID = RR1.USER_ID 
GROUP BY R2.RESTAURANT_ID) as temp) >= ALL((SELECT MAX(stddev) 
FROM (SELECT stddev(R3.MOOD + R3.STAFF + R3.PRICE + R3.FOOD) 
FROM RATING R3 
GROUP BY R3.USER_ID, R3.RESTAURANT_ID) as temp))) AND R.USER_ID = RR.USER_ID AND R.RESTAURANT_ID = RS.RESTAURANT_ID AND RS.RESTAURANT_ID IN 
(SELECT RS2.RESTAURANT_ID 
FROM  RESTAURANT RS2 
GROUP BY RS2.RESTAURANT_ID 
HAVING (SELECT MAX(stddev) 
FROM (SELECT stddev(R4.MOOD + R4.STAFF + R4.PRICE + R4.FOOD) as stddev 
FROM RATING R4 
WHERE R4.RESTAURANT_ID = RS2.RESTAURANT_ID 
GROUP BY R4.RESTAURANT_ID, R4.USER_ID) as temp) >= ALL((SELECT MAX(stddev) 
FROM (SELECT stddev(R5.MOOD + R5.STAFF + R5.PRICE + R5.FOOD) 
FROM RATING R5
GROUP BY R5.USER_ID, R5.RESTAURANT_ID) as temp)));


