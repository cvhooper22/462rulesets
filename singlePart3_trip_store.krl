ruleset trip_store {
  meta {
    name "Trip Store"
    description << Takes care of trip storate for part 3 of the Single Pico CS 462 lab >>
    author "Matt Freeman"
    logging on
    sharing on
  }

  rule collect_trips {
    select when explicit trip_processed mileage "(\d*)" setting(mileage)
    pre {
      now = time:now();
      uuid = "TRIP-" + random:uuid();
      init_all = {
        "TRIP-0": {
          timestamp: "init",
          mileage: "init" 
        }
      }
    }
    always {
      set ent:all_trips init if not ent:all_trips{["TRIP-0"]};
      set ent:all_trips{[uuid,"timestamp"]} now;
      set ent:all_trips{[uuid,"mileage"]} mileage;
    }
    
  }

  rule collect_long_trips {
    select when explicit found_long_trip
    pre {
      now = time:now();
      uuid = "LTRIP-" + random:uuid();
      init_long = {
        "LTRIP-00": {
          timestamp: "init",
          mileage: "init"
        }
      }
    }
    always {
      set ent:long_trips init_long if not ent:long_trips{["LTRIP-00"]};
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