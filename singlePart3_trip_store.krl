  ruleset trip_store {
    meta {
      name "Trip Store"
      description << Takes care of trip storage for part 3 of the Single Pico CS 462 lab >>
      author "Matt Freeman"
      logging on
      sharing on
      provides trips, long_trips, short_trips
    }
    global {
      trips = function() {
        all_trips = ent:all_trips.pick("$..*");
        all_trips
      }

      long_trips = function() {
        long = ent:long_trips.pick("$..*");
        long
      }

      short_trips = function() {
        trips = trips();
        short = trips.filter(function(trip){trip["mileage"] < 501 }); // 500 is a long trip
        short
      }
    }

    rule collect_trips {
      select when explicit trip_processed mileage "(\d*)" setting(mileage)
      pre {
        foo = event:attrs().klog(">>>> are there attributes? <<<<");
        now = time:now();
        uuid = "TRIP-" + random:uuid();
        init_all = {
          "TRIP-0": {
            "timestamp": "init",
            "mileage": "init" 
          }
        }
      }
      always {
        log ("all_trips is:" + ent:all_trips);
        set ent:all_trips init if not ent:all_trips{["TRIP-0"]};
        set ent:all_trips{[uuid,"timestamp"]} now;
        set ent:all_trips{[uuid,"mileage"]} mileage;
      }
      
    }

    rule collect_long_trips {
      select when explicit found_long_trip mileage "(\d*)" setting(mileage)
      pre {
        foo = event:attrs().klog(">>>> are there attributes? <<<<");
        now = time:now();
        uuid = "LTRIP-" + random:uuid();
        init_long = {
          "LTRIP-00": {
            "timestamp": "init",
            "mileage": "init"
          }
        }
      }
      always {
        set ent:long_trips init_long if not ent:long_trips{["LTRIP-00"]};
        log("long_trips: " + ent:long_trips);
        set ent:long_trips{[uuid,"timestamp"]} now;
        set ent:long_trips{[uuid,"mileage"]} mileage;
      }
    }

    rule clear_trips {
      select when car trip_reset
      always {
        set ent:all_trips {};
        set ent:long_trips {};
      }
    }
  }