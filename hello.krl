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

    user_by_name = function(full_name) {
      all_users = users();
      filtered_users = all_users.filter( function(user_id, val){
          constructed_name = val{["name","first"]} + " " + val{["name","last"]};
          (constructed_name eq full_name);
        });
      user = filtered_users.head().klog("matching user: ");
      user
    };
 
  }
  rule hello_world {
    select when echo hello
    pre {
      name = event:attr("name").defaultsTo("HAL 9000","no name passed");
      full_name = name.split(re/\s/);
      first_name = full_name[0].klog("first name: ");
      last_name = full_name[1].klog("last name: ");
      matching_user = user_by_name(name).klog("user result: ");
      user_id = matching_user.keys().head().klog("id: ");
      new_user = {
        "id"    : last_name.lc() + "_" + first_name.lc(),
        "first" : first_name,
        "last"  : last_name
      };
    }
    {
      send_directive("say") with
        greeting = "Hello #{default_name}";
    }
    always {
      log ("LOG says Hello " + default_name);
    }
  }

  rule new_user {
    select when explicit new_user
    pre{
      id = event:attr("id").klog("our passed in Id: ");
      first = event:attr("first").klog("our passed in first name: ");
      last = event:attr("last").klog("our passed in last name: ");
      new_user = {
          "name":{
            "first":first,
            "last":last
          },
        "visits": 1
      };
    }
    {
      send_directive("say") with
        something = "Hello #{first} #{last}";
      send_directive("new_user") with
        passed_id = id and
        passed_first = first and
        passed_last = last;
    }
    always{
      set ent:name{[id]} new_user;
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