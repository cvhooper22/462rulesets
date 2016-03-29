ruleset manage_fleet {
  meta {
    name "Manage Fleet"
    description << A Fleet managing set for the Multiple Pico CS 462 lab >>
    author "Matt Freeman"
    logging on
    use module b507199x5 alias wranglerOS
  }
  global {
    vehicles = function() {
      // return all vehicles I know about
      wrangler_children = wranglerOS:children();
      children = wrangler_children{"children"};
      children
    };
  }

  rule create_vehicle {
    select when car new_vehicle
    pre {
      name = event:attr("name") || "Car-"+math:random(999);
      my_eci = meta:eci();
      attributes = {};
      attributes.put(["Prototype_rids"],"b507731x3.prod;b507731x4.prod");
      attributes.put(["name"],name]);
      attributes.put({"fleet_channel": my_eci, "_async": 0});
      // _async is supposed to make sure it is completed before proceeding
      subscription_attributes = {}.put(["name"], name)
                      .put(["name_space"],"462_Multiple_Picos")
                      .put(["my_role"],"Fleet")
                      .put(["your_role"],"Vehicle")
                      .put(["target_eci"],my_eci.klog("target Eci: "))
                      ;
    }
    {
      event:send({"cid":meta:eci()}, "wrangler", "child_creation")
      with attrs = attributes.klog("attributes: ");
    }
    fired {
      raise wrangler event "subscribe"
        with namespace = common:namespace()
          and relationship = "Vehicle-Fleet"
          and channelName = 
    }
  }

  rule delete_vehicle {
    select when car unneeded_vehicle child_pci "(.+)" setting(child_id)
    {
      // delete the pico
    }
    fired {
      // delte the subscription
    }
  }
}