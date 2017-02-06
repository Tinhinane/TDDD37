delimiter //
CREATE FUNCTION calculatePrice(flight_number INT) RETURNS DOUBLE
BEGIN  
  
    
    DECLARE n INTEGER;
    DECLARE reg_day VARCHAR(10);
    DECLARE reg_year INTEGER;
    DECLARE booked_passengers DOUBLE;
    DECLARE route_price DOUBLE;
    DECLARE day_factor DOUBLE;
    DECLARE profit_factor DOUBLE;
    DECLARE total DOUBLE;
    
    SELECT calculateFreeSeats(flight_number) INTO n;
    SET booked_passengers := ((n + 1)/4);
    
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
    
    SET total := route_price*booked_passengers*profit_factor*day_factor;             
    RETURN total;
END;
//
delimiter ;
