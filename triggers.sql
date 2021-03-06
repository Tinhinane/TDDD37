
DELIMITER //
CREATE PROCEDURE update_passengers(IN reservation_number INTEGER, IN passport_number INTEGER)
BEGIN
   DECLARE ticket_number INTEGER;
   SET ticket_number=FLOOR(RAND() * 401) + 100;
   UPDATE PassengerReservation 
   SET ticketNbr = ticket_number
   WHERE reservation=reservation_number AND passportNbr=passport_number;
END;
//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE cursor_for_passports(IN reservation_number INTEGER)
BEGIN
  DECLARE done INT DEFAULT FALSE;
  DECLARE b INT;
  DECLARE passports_cursor CURSOR FOR SELECT passportNbr FROM PassengerReservation WHERE reservation=reservation_number;

  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

  OPEN passports_cursor;
  
  read_loop: LOOP
    FETCH passports_cursor INTO b;
    IF done THEN
      LEAVE read_loop;
    END IF;
    CALL update_passengers(reservation_number, b);
  END LOOP;

  CLOSE passports_cursor;
END;
//
DELIMITER ;

DELIMITER //
CREATE TRIGGER ticket_generator AFTER INSERT 
ON Booking
FOR EACH ROW 
BEGIN
    CALL cursor_for_passports(NEW.ref_reservation);
END;
//
DELIMITER ;



-- Trigger for contacts in Passenger Table
DELIMITER //
CREATE TRIGGER ticket_generator AFTER INSERT 
ON Contact
FOR EACH ROW 
BEGIN
    CALL cursor_for_passports(NEW.ref_reservation);
END;
//
DELIMITER ;


