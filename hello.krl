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

    users = function() {
      users = ent:name;
      users
    };

    name = function(id) {
      all_users = users();
      first_name = all_users{[id,"name","first"]}.defaultsTo("HAL","could not find user. ");
      last_name = all_users{[id,"name","last"]}.defaultsTo("9000","could not find user. ");
      name = first_name + " " + last_name;
      name;
    };
 
  }
  rule hello_world {
    select when echo hello
    pre {
      id = event:attr("id").defaultsTo("_0","no id passed.").klog("Passed in id: ");
      name_map = ent:name.klog("The name map is: ");
      default_name = name(id)
    }
    {
      send_directive("say") with
        greeting = "Hello #{default_name}";
    }
    always {
      log ("LOG says Hello " + default_name);
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