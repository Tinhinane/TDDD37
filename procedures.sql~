-- addYear(year, factor)
delimiter //
CREATE PROCEDURE addYear(IN iyear INTEGER, IN ifactor DOUBLE)
BEGIN 
    INSERT INTO Year(year, factor)
    VALUES (iyear, ifactor);
END;
//
delimiter ;

-- addDay(year, day, factor)
delimiter //
CREATE PROCEDURE addDay(IN iyear INTEGER, IN iday VARCHAR(10), IN ifactor DOUBLE)
BEGIN 
    INSERT INTO Day(day, year, factor)
    VALUES (iday, iyear, ifactor);
END;
//
delimiter ;

-- addDestination(airport_code, name, country)
delimiter //
CREATE PROCEDURE addDestination(IN iairport_code VARCHAR(3), IN iname VARCHAR(30), IN icountry VARCHAR(30))
BEGIN 
    INSERT INTO Destination(airportCode, name, country)
    VALUES (iairport_code, iname, icountry);
END;
//
delimiter ;

-- addRoute(departure_airport_code, arrival_airport_code, year, routeprice)
delimiter //
CREATE PROCEDURE addRoute(IN departure_airport_code VARCHAR(3), IN arrival_airport_code VARCHAR(3), IN year INTEGER, routePrice DOUBLE)
BEGIN
    INSERT INTO Route(routePrice, year, departure, arrival)
    VALUES(routePrice, year, departure_airport_code, arrival_airport_code);
END;
//
delimiter ;

-- helful: findRoute 
delimiter //
CREATE PROCEDURE findRoute(IN departure_airport_code VARCHAR(3), IN arrival_airport_code VARCHAR(3), IN iyear INTEGER, OUT param_id INT)
BEGIN
   SELECT id INTO param_id FROM Route 
   WHERE year=iyear AND arrival=arrival_airport_code AND departure=departure_airport_code;
END;
//
delimiter ;


-- helpful: findFlight
DELIMITER //
CREATE PROCEDURE findFlight(IN departure_airport_code VARCHAR(3), IN arrival_airport_code VARCHAR(3), IN iyear INTEGER, IN iweek INTEGER, IN iday VARCHAR(10), IN departure_time TIME, OUT flight_id INT)
BEGIN
    DECLARE id_weekly_flight INTEGER;
    
    CALL findRoute(departure_airport_code,arrival_airport_code, iyear,@id);
    SELECT DISTINCT id INTO id_weekly_flight FROM WeeklyFlight 
    WHERE day=iday AND year=iyear AND departureTime=departure_time AND route=@id;
    
    SELECT flightNumber INTO flight_id FROM Flight 
    WHERE week=iweek AND weeklyFlight=id_weekly_flight;
   
END;
//
DELIMITER ;



-- addFlight
delimiter //
CREATE PROCEDURE addFlight(IN departure_airport_code VARCHAR(3), IN arrival_airport_code VARCHAR(3), IN iyear INTEGER, IN iday VARCHAR(10), IN departure_time TIME)
BEGIN
    DECLARE lastWeeklyFlightAdded INTEGER;
    DECLARE i INT UNSIGNED DEFAULT 1;
    INSERT INTO WeeklyFlight(departureTime, route, day, year)
    VALUES ( departure_time, 
             (SELECT id FROM Route 
                WHERE year=iyear AND arrival=arrival_airport_code AND             departure=departure_airport_code)
             , 
             iday,
             iyear);
     SET lastWeeklyFlightAdded := LAST_INSERT_ID();
     WHILE i < 53 DO
        INSERT INTO Flight (week, weeklyFlight) VALUES (i, lastWeeklyFlightAdded);
        SET i := i + 1;
     END WHILE;
END;
//
delimiter ;

-- addReservation
DELIMITER //
CREATE PROCEDURE addReservation(IN departure_airport_code VARCHAR(3), IN arrival_airport_code VARCHAR(3), IN iyear INTEGER, IN iweek INTEGER, IN iday VARCHAR(10), IN time TIME, IN number_of_passengers INTEGER, OUT output_reservation_nr INTEGER)
BEGIN
    
    DECLARE reservation_number INTEGER;
    DECLARE verif_seats INTEGER;
    
    CALL findFlight(departure_airport_code,arrival_airport_code,iyear,iweek,iday,time,@flight_id);
    SET reservation_number = FLOOR(RAND() * 401) + 100;

    SELECT calculateFreeSeats(@flight_id) INTO verif_seats;

    IF @flight_id IS NOT NULL THEN
        IF verif_seats < number_of_passengers THEN
            SELECT "There are not enough seats available on the chosen flight" AS "Message";
        ELSE
            INSERT INTO Reservation(reservationNbr, flight)
            VALUES(reservation_number, @flight_id);
            SET output_reservation_nr := reservation_number;
        END IF;
    ELSE
        SELECT "There exist no flight for the given route, day, year and time" AS "Message";
    END IF;
END;
//
DELIMITER ;
-- check if contact exists on this reservation
DELIMITER // 
CREATE PROCEDURE checkContact(IN reservation_nr INTEGER)
BEGIN 
    
END;
//
DELIMITER ;

-- addPassenger
DELIMITER //
CREATE PROCEDURE addPassenger(IN reservation_nr INTEGER, IN passport_number INTEGER, IN iname VARCHAR(30))
BEGIN
    DECLARE verif_reservation INTEGER;
    DECLARE verif_is_booked INTEGER;
    DECLARE verif_if_contact VARCHAR(30);
    
    SELECT ReservationNbr INTO verif_reservation FROM Reservation 
    WHERE ReservationNbr=reservation_nr;
    SELECT payment INTO verif_is_booked FROM Booking WHERE ref_reservation=reservation_nr;
    
    SELECT DISTINCT contact INTO verif_if_contact FROM Passenger WHERE passportNbr IN(SELECT passportNbr FROM PassengerReservation WHERE reservation=reservation_nr) AND contact IS NOT NULL;

    IF verif_is_booked IS NULL THEN
        IF verif_reservation IS NOT NULL THEN
            INSERT INTO Passenger(passportNbr, name, contact)
            VALUES(passport_number, iname, verif_if_contact);
            INSERT INTO PassengerReservation(passportNbr, reservation)
            VALUES(passport_number, reservation_nr);   
        ELSE
            SELECT "The given reservation does not exist" AS "Message";
        END IF;
    ELSE
        SELECT "The booking has already been payed and no futher passengers can be added" AS "Message";        
    END IF;
END;
//
DELIMITER ;

-- addContact
DELIMITER //
CREATE PROCEDURE addContact(IN reservation_nr INTEGER, IN passport_number INTEGER, IN iemail VARCHAR(30), IN iphone BIGINT)
BEGIN
    DECLARE verif_reservation INTEGER;
    DECLARE verif_pass INTEGER;
        
    SELECT ReservationNbr INTO verif_reservation FROM Reservation 
    WHERE ReservationNbr=reservation_nr;
    
    SELECT passportNbr INTO verif_pass FROM PassengerReservation 
    WHERE reservation=reservation_nr AND passportNbr=passport_number;
    
        IF verif_pass IS NOT NULL THEN         
            IF verif_reservation IS NOT NULL THEN        
                    INSERT INTO Contact(email, phone) VALUES(iemail, iphone)
                        ON DUPLICATE KEY UPDATE email=iemail;
                    -- for each!
                    UPDATE Passenger
                    SET contact=iemail 
                    WHERE passportNbr IN(SELECT passportNbr FROM PassengerReservation WHERE reservation=reservation_nr);
            ELSE
                SELECT "The given reservation does not exist" AS "Message";
            END IF;
        ELSE
            SELECT "The person is not a passenger of the reservation" AS "Message";
        END IF;
  
END;
//
DELIMITER ;

-- addPayment
DELIMITER //
CREATE PROCEDURE addPayment(IN reservation_nr INTEGER, IN card_holder VARCHAR(30), IN credit_card_number BIGINT)
BEGIN
    DECLARE verif_reservation INTEGER;
    DECLARE verif_contact VARCHAR(30);
    DECLARE verif_is_payed INTEGER;
    DECLARE id_payment INTEGER;
    DECLARE check_free INTEGER;
    DECLARE count_pay_for INTEGER;
    DECLARE flight_number INTEGER;
    
    SELECT flight INTO flight_number FROM Reservation WHERE reservationNbr=reservation_nr;
    SELECT calculateFreeSeats(flight_number) INTO check_free;
    SELECT COUNT(*) INTO count_pay_for FROM PassengerReservation WHERE reservation=reservation_nr;
    
    SELECT ReservationNbr INTO verif_reservation FROM Reservation 
    WHERE ReservationNbr=reservation_nr;
    
    SELECT DISTINCT contact INTO verif_contact FROM Passenger WHERE passportNbr IN(
        SELECT passportNbr FROM PassengerReservation WHERE reservation=reservation_nr);

    SELECT payment INTO verif_is_payed FROM Booking WHERE ref_reservation=reservation_nr;

    IF check_free > count_pay_for THEN  
        IF verif_is_payed IS NULL THEN
            IF verif_reservation IS NOT NULL THEN    
                IF verif_contact IS NOT NULL THEN
                    INSERT INTO Payment(cardNumber, cardHolder)
                    VALUES(credit_card_number,card_holder);
                    
                    SET id_payment := LAST_INSERT_ID();
                    INSERT INTO Booking(ref_reservation, payment)
                    VALUES(reservation_nr, id_payment);
                ELSE
                    SELECT "The reservation has no contact yet" as "Message";
                END IF;
            ELSE
                SELECT "The given reservation number does not exist" as "Message";
            END IF;
        ELSE
            SELECT "The booking has already been payed and no futher passengers can be added" as "Message";
        END IF;
    ELSE
        SELECT "There are not enough seats available on the flight anymore, deleting reservation!" AS "Message";
        DELETE FROM PassengerReservation WHERE reservation=reservation_nr;
        DELETE FROM Reservation WHERE reservationNbr=reservation_nr;
        DELETE FROM Passenger WHERE contact=verif_contact;
        DELETE FROM Contact WHERE email=verif_contact;
        
    END IF; 
END;
//
DELIMITER ;



