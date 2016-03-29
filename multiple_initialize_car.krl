ruleset car_initialize {
  meta {
    name "Initialize Car"
    description << Ruleset with just one rule to help car subscribe to fleet >>
    author "Matt Freeman"
    logging on
    use module b507199x5 alias wranglerOS
  }

  rule subscribe_to_fleet {
    select when wranglerOS init_events
    pre {
      // find parent
      parent_results = wranglerOS:parent();
      parent = parent_results{'parent'}.klog("My Parent: ");
      parent_eci = parent[0];
      attrs = {}.put(["name"],"Fleet")
                .put(["name_space"],"462_Multi_Picos")
                .put(["my_role"],"vehicle")
                .put(["your_role"],"fleet")
                .put(["target_eci"],parent_eci.klog("target ECI: "))
                .put(["channel_type"],"462_Multiple")
                .put(["attrs"],"success");
    }
    always {
      raise wrangler event "subscription"
      attributes attrs;
    }
  }
}