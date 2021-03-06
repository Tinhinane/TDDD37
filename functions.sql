CREATE FUNCTION dept_size( IN dno INT )
 RETURNS VARCHAR(7)
BEGIN
# number of employees
DECLARE n INT;
SELECT COUNT(*) INTO n FROM emp WHERE Dept=dno;
IF n > 25 THEN RETURN "large"
ELSEIF n > 10 THEN RETURN "medium"
ELSE RETURN "small"
END IF;
END;


-- Get Free Seats
DELIMITER //
CREATE FUNCTION calculateFreeSeats(IN flight_number INT) RETURNS INT
BEGIN

    DECLARE free INTEGER;
    SELECT nbrOfFreeSeats INTO free FROM Flight WHERE flightNumber = flight_number;
    RETURN free;

END;
//
DELIMITER ;
    
-- Calculate flight price
/*
DECLARE route_price INTEGER;
    DECLARE day_factor DOUBLE;
    DECLARE profit_factor DOUBLE;

*/

SELECT routePrice FROM Route WHERE id IN(
    SELECT route FROM WeeklyFlight WHERE id IN(
                SELECT weeklyFlight FROM Flight WHERE  flightNumber = 103));




DELIMITER //
CREATE FUNCTION calculatePrice(flight_number INT) RETURNS DOUBLE
BEGIN    


    DECLARE n INTEGER;
    DECLARE reg_day VARCHAR(10);
    DECLARE reg_year INTEGER;
    DECLARE booked_passengers DOUBLE;
    DECLARE route_price DOUBLE;
    DECLARE day_factor DOUBLE;
    DECLARE profit_factor DOUBLE;
    DELCARE total DOUBLE;
    
    SELECT nbrOfFreeSeats INTO n FROM Flight WHERE flightNumber = flight_number;
    SET booked_passengers := ((40 - n + 1)/4);
    
    SELECT factor INTO profit_factor FROM Year WHERE year IN(
        SELECT DISTINCT year FROM Day WHERE year IN(
            SELECT year FROM WeeklyFlight WHERE id IN(
                SELECT weeklyFlight FROM Flight WHERE  flightNumber = flight_number)));

    SELECT day INTO reg_day FROM WeeklyFlight WHERE id IN
     (SELECT weeklyFlight FROM Flight WHERE  flightNumber = flight_number);
    SELECT DISTINCT year INTO reg_year FROM WeeklyFlight WHERE id IN
     (SELECT weeklyFlight FROM Flight WHERE  flightNumber = flight_number);
    SELECT factor INTO day_factor FROM Day WHERE day= reg_day AND year=reg_year;
    
    SELECT routePrice INTO route_price FROM Route WHERE id IN(
        SELECT route FROM WeeklyFlight WHERE id IN(
                    SELECT weeklyFlight FROM Flight WHERE  flightNumber = flight_number));
    
    
    SET total := (route_price * booked_passengers * profit_factor * day_factor);
    
    RETURN total;
END;
//
DELIMITER ;

Day
+----------+------+--------+
| day      | year | factor |
+----------+------+--------+
| Monday   | 2010 |      1 |
| Saturday | 2011 |      2 |
| Sunday   | 2011 |    2.5 |
| Tuesday  | 2010 |    1.5 |
+----------+------+--------+

Year
+------+--------+
| year | factor |
+------+--------+
| 2010 |    2.3 |
| 2011 |    2.5 |
+------+--------+

RoutePrice
+----+------------+------+-----------+---------+
| id | routePrice | year | departure | arrival |
+----+------------+------+-----------+---------+
|  1 |       2000 | 2010 | MIT       | HOB     |
|  2 |       1600 | 2010 | HOB       | MIT     |
|  3 |       2100 | 2011 | MIT       | HOB     |
|  4 |       1500 | 2011 | HOB       | MIT     |
+----+------------+------+-----------+---------+

+--------------+----------------+------+--------------+
| flightNumber | nbrOfFreeSeats | week | weeklyFlight |
+--------------+----------------+------+--------------+
|           52 |             40 |    1 |            2 |
|           53 |             40 |    2 |            2 |
|           54 |             40 |    3 |            2 |




