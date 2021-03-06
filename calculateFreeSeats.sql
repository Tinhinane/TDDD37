DELIMITER //
CREATE FUNCTION calculateFreeSeats(flight_number INT) RETURNS INTEGER
BEGIN
    DECLARE free_seats INTEGER DEFAULT 40;
    CALL cursor_for_flight_reservation(flight_number, @output);
    SET free_seats:= free_seats-@output;
    RETURN free_seats;
END;
//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE find_passengers(IN reservation_number INTEGER, OUT output_number INTEGER)
BEGIN
    DECLARE count_passports INTEGER;
    SELECT COUNT(*) INTO count_passports FROM PassengerReservation WHERE reservation=reservation_number;
    SET output_number:= count_passports;
END;
//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE cursor_for_flight_reservation(IN flight_number INTEGER, OUT total_passengers INTEGER)
BEGIN
  DECLARE done INT DEFAULT FALSE;
  DECLARE b INT;
  DECLARE acc INT DEFAULT 0;
  DECLARE flight_reservation_cursor CURSOR FOR SELECT reservationNbr FROM Reservation WHERE reservationNbr IN(SELECT ref_reservation FROM Booking) AND flight=flight_number;

  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

  OPEN flight_reservation_cursor;
  
  read_loop: LOOP
    FETCH flight_reservation_cursor INTO b;
    IF done THEN
      LEAVE read_loop;
    END IF;
    CALL find_passengers(b, @a);
    SET acc:= acc + @a;
  END LOOP;
  CLOSE flight_reservation_cursor;
  SET total_passengers:=acc;
END;
//
DELIMITER ;
