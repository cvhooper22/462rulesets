ruleset manage_fleet {
  meta {
    name "Manage Fleet"
    description << A Fleet managing set for the Multiple Pico CS 462 lab >>
    author "Matt Freeman"
    logging on
    sharing on
    provides vehicles, subscriptions
    use module b507199x5 alias wranglerOS
    use module a169x625 alias CloudOS
  }
  global {
    vehicles = function() {
      // return all vehicles I know about
      wrangler_children = wranglerOS:children();
      children = wrangler_children{"children"};
      children
    };

    subscriptions = function() {
      sub_results = wranglerOS:subscriptions();
      subscriptions = sub_results{"subscriptions"};
      subscriptions
    }

  }

  rule create_vehicle {
    select when car new_vehicle
    pre {
      name = event:attr("name") || "Car-"+math:random(999);
      my_eci = meta:eci();
      attr = {}.put(["Prototype_rids"],"b507731x3.prod;b507731x4.prod;b507731x5.prod")
               .put(["name"],name)
               .put({"fleet_channel": my_eci, "_async": 0});
    }
    always {
      raise wrangler event "child_creation"
      attributes attr.klog("child creation attributes: ");
      log("create child for: " + child);
    }
  }

  rule accept_child_subscription {
    // actually accepts all subscriptions
    select when wrangler inbound_pending_subscription_added
    pre {
      attributes = event:attrs().klog("subscription attrs: ");
    }
    always {
      raise wrangler event 'pending_subscription_approval'
        attributes attributes;
        log("auto acception child subscription" + event:attrs());
    }
  }

  rule delete_vehicle {
    select when car unneeded_vehicle
    pre {
      name = event:attr("name").klog("name to delete: ");
      subscription_results = wranglerOS:subscriptions();
      subscriptions = subscription_results{"subscriptions"};
      to_be_deleted = subscriptions.filter(function(sub){sub{"channelName"} eq name})
                                   .head()
                                   .klog(">>>>>>> to be deleted >>>>>>");
      delete_eci = to_be_deleted{"eventChannel"}.klog('channel eci to delete');
    }
    {
      event:send({"eci": delete_eci}, "wrangler", "child_deletion")
        with attrs = attributes.klog('deletion attributes');

      // unsubscribe
      event:send({"cid": delete_eci}, "wrangler", "subscription_cancellation") 
       with attrs = {}.put(["channel_name"], name).klog("attributes for unsubscription: ");
    }
  }
}