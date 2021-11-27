<h1 align="center">
  Hoon Snippets
</h1>
<p align="center"> Various hoon code snippest which developers may find useful to include/use/fork for their own use cases.</p>

<p align="center">Hoon is Urbit's user-facing programming language. For more information about Hoon, check out the <a href = "https://urbit.org/docs/glossary/hoon">Hoon Documentation</a> .</p>

## `camel.hoon`

Camel-case and kebab-case conversion library intended for use with JS.

## `%herald`

Spider thread to dispatch Dojo commands for an external caller
without a subscription.  Uses `%page` to dispatch the single call.

`%herald` should receive a message containing a Dojo command, execute
the command, wrap the output as a JSON, and return the value.

```
curl -i --header "Content-Type: application/json" \
     --cookie "urbauth-~zod=0v6.hurgu.sburg.uszop" \
     --request POST \
     --data '{"json": "|mount %base"}' \
     http://localhost:8080/spider/base/json/herald/json
```

This thread streamlines the process of external apps installing software,
issuing pokes to other ships on the network, evaluating and retrieving
the return value of arbitrary Hoon code, and exposing the full
functionality of the Urbit ship through the Airlock and Urbit Visor.

The current version of `%herald` only emits commands to Dojo but does not
return any result.
