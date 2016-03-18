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
      id = event:attr("id").defaultsTo("_0","no id passed.");
      first = ent:name{[id,"name","first"]};
      last = ent:name{[id,"name","last"]};
    }
    {
      send_directive("say") with
        something = "Hello #{first} #{last}";
    }
    always {
      log ("LOG says Hello " + first + " " + last);
    }
  }

  rule store_name {
    select when name hello
    pre {
      id = event:attr("id").klog("Out passed in id: ");
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
      passed_name = event:attr("name").klog("our passed in name: ").klog("our passed in Name: ");
    }
    {
      send_directive("store_name") with
        passed_id = id and
        passed_first_name = first_name and 
        passed_last_name = last_name
    }
    always {
      set ent:name init if not ent:name{["_0"]};
      set ent:name{[id,"name","first"]} first;
      set ent:name[[id,"name","last"]]} last;
    }
  }
 
}