SELECT 'Creating tables' AS 'Message';
-- Create tables
CREATE TABLE Destination(
    airportCode VARCHAR(3),
    name VARCHAR(30),
    country VARCHAR(30),
    CONSTRAINT pk_destination PRIMARY KEY(airportCode)
);

CREATE TABLE Year(
    year INTEGER NOT NULL, 
    factor DOUBLE NOT NULL, 
    CONSTRAINT pk_year PRIMARY KEY(year)
); 

CREATE TABLE Day(
   day VARCHAR(10),
   year INTEGER NOT NULL,
   factor DOUBLE NOT NULL,
   CONSTRAINT pk_day PRIMARY KEY(day, year),
   CONSTRAINT fk_day_year FOREIGN KEY(year) REFERENCES Year(year)
);

CREATE TABLE Route(
    id INTEGER NOT NULL AUTO_INCREMENT, 
    routePrice DOUBLE DEFAULT 0, 
    year INTEGER, 
    departure VARCHAR(3), 
    arrival VARCHAR(3),
 
    CONSTRAINT pk_route PRIMARY KEY(id)
);

CREATE TABLE WeeklyFlight(
    id INTEGER NOT NULL AUTO_INCREMENT, 
    departureTime TIME, 
    route INTEGER, 
    day VARCHAR(10), 
    year INTEGER, 
    
    CONSTRAINT pk_weeklyflight PRIMARY KEY(id)
);

-- delete nbr of free seats
CREATE TABLE Flight(
    flightNumber INTEGER NOT NULL AUTO_INCREMENT, 
    week INTEGER NOT NULL, 
    weeklyFlight INTEGER,
    
    CONSTRAINT pk_flight PRIMARY KEY(flightNumber) 
);

CREATE TABLE Reservation(
    reservationNbr INTEGER NOT NULL,
    flight INTEGER NOT NULL, 
    CONSTRAINT pk_reservation PRIMARY KEY(reservationNbr)
);

CREATE TABLE Contact(
    email VARCHAR(30) NOT NULL, 
    phone BIGINT, 
    
    CONSTRAINT pk_contact PRIMARY KEY(email)
);

-- Use only one name instead of first name and last name
CREATE TABLE Passenger(
     passportNbr INTEGER NOT NULL,
     name VARCHAR(30),
     contact VARCHAR(30),
     
     CONSTRAINT pk_passenger PRIMARY KEY(passportNbr)
);

CREATE TABLE PassengerReservation(
    passportNbr INTEGER NOT NULL,
    reservation INTEGER NOT NULL, 
    ticketNbr INTEGER, 
    
    CONSTRAINT pk_PassengerReservation PRIMARY KEY(passportNbr, reservation)
);

-- removed price and contact
-- drop foreign key payment contact
CREATE TABLE Payment(
   id INTEGER NOT NULL AUTO_INCREMENT, 
   cardNumber BIGINT NOT NULL,
   cardHolder VARCHAR(30),
    
   CONSTRAINT pk_payment PRIMARY KEY(id)
);

CREATE TABLE Booking(
    ref_reservation INTEGER NOT NULL,
    payment INTEGER NOT NULL, 
    
    CONSTRAINT pk_booking PRIMARY KEY(ref_reservation)
);

-- Add foreign keys
SELECT 'Creating foreign keys' AS 'Message';
ALTER TABLE Route ADD CONSTRAINT fk_route_year FOREIGN KEY(year) REFERENCES Year(year);
ALTER TABLE Route ADD CONSTRAINT fk_route_departure FOREIGN KEY(departure) REFERENCES Destination(airportCode);
ALTER TABLE Route ADD CONSTRAINT fk_route_arrival FOREIGN KEY(arrival) REFERENCES Destination(airportCode);

ALTER TABLE WeeklyFlight ADD CONSTRAINT fk_wf_route FOREIGN KEY(route) REFERENCES Route(id);
ALTER TABLE WeeklyFlight ADD CONSTRAINT fk_wf_day FOREIGN KEY(day) REFERENCES Day(day);
ALTER TABLE WeeklyFlight ADD CONSTRAINT fk_wf_year FOREIGN KEY(year) REFERENCES Year(year);  
    
ALTER TABLE Flight ADD CONSTRAINT fk_flight_wf FOREIGN KEY(weeklyFlight) REFERENCES WeeklyFlight(id);

ALTER TABLE Reservation ADD CONSTRAINT fk_reservation_flight FOREIGN KEY(flight) REFERENCES Flight(flightNumber);  

ALTER TABLE Passenger ADD CONSTRAINT fk_passenger_contact FOREIGN KEY(contact) REFERENCES Contact(email); 

ALTER TABLE PassengerReservation ADD CONSTRAINT fk_RP_reservation FOREIGN KEY(reservation) REFERENCES Reservation(reservationNbr);
ALTER TABLE PassengerReservation ADD CONSTRAINT fk_RP_passenger FOREIGN KEY(passportNbr) REFERENCES Passenger(passportNbr);

ALTER TABLE Booking ADD CONSTRAINT fk_booking_payment FOREIGN KEY(payment) REFERENCES Payment(id);
ALTER TABLE Booking ADD CONSTRAINT fk_booking_reservation FOREIGN KEY(ref_reservation) REFERENCES Reservation(reservationNbr);


