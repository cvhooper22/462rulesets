ruleset echo {
  meta {
    name "Echo"
    description << Echo ruleset for part 1 of the Single Pico CS 462 lab >>
    author "Matt Freeman"
    logging on
    sharing on
  }

  rule hello {
    select when echo hello
    send_directive("say") with
      something = "Hello World"
  }

  rule message {
    select when echo message input "(.*)" setting(message)
    send_directive("say") with
      something = message
  }
}