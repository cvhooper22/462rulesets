ruleset track_car_trips {
  meta {
    name "Track Trips Better"
    description << Track Trips ruleset for part 1 of the Single Pico CS 462 lab >>
    author "Matt Freeman"
    logging on
    sharing on
  }

  rule process_trip {
    select when car new_trip mileage "(.*)" setting(mileage)
    send_directive("trip") with
      trip_length = mileage
  }
}