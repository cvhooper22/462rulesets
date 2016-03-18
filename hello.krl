ruleset hello_world {
  meta {
    name "Hello World"
    description <<
A first ruleset for the Quickstart
>>
    author "Phil Windley"
    logging on
    sharing on
    provides hello
 
  }
  global {
    hello = function(obj) {
      msg = "Hello " + obj
      msg
    };
 
  }
  rule hello_world {
    select when echo hello
    pre {
      id = event:attr("id").defaultsTo("_0","no id passed.").klog("Passed in id: ");
      name_map = ent:name.klog("The name map is: ");
      first = ent:name{[id,"name","first"]}.klog("First retrieved: ");
      last = ent:name{[id,"name","last"]};
    }
    {
      send_directive("say") with
        greeting = "Hello #{first} #{last}";
    }
    always {
      log ("LOG says Hello " + first + " " + last);
    }
  }

  rule store_name {
    select when name hello
    pre {
      id = event:attr("id").klog("Our passed in id: ");
      first_name = event:attr("first").klog("Passed in first name: ");
      last_name = event:attr("last").klog("Passed in last name: ");
      init = {
            "_0": {
              "name" : {
                "first" : "GLaDOS",
                "last" :  ""
              }
            }  
      }
    }
    {
      send_directive("store_name") with
        passed_id = id and
        passed_first_name = first_name and 
        passed_last_name = last_name
    }
    always {
      set ent:name init if not ent:name{["_0"]};
      set ent:name{[id,"name","first"]} first_name;
      set ent:name{[id,"name","last"]} last_name;
    }
  }
 
}