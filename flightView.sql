CREATE VIEW allFlights AS
    SELECT Route.departure AS 'departure_city_name',
    Route.arrival AS 'destination_city_name', 
    WeeklyFlight.departureTime AS 'departure_time',
    WeeklyFlight.day AS 'departure_day',
    Flight.week AS 'departure_week',
    WeeklyFlight.year AS 'departure_year',
    calculateFreeSeats(Flight.flightNumber) AS 'nr_of_free_seats',
    calculatePrice(Flight.flightNumber) AS 'current_price_per_seat'
    FROM Flight, WeeklyFlight, Route
	WHERE Flight.weeklyFlight= WeeklyFlight.id AND WeeklyFlight.route=Route.id
