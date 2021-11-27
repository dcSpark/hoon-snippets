  ::
::::  herald.hoon
::
::      Spider thread to dispatch Dojo commands for an external caller
::      without a subscription.
::
::    %herald should receive a message containing a Dojo command, execute
::    the command, wrap the output as a JSON, and return the value.
::
::    ```
::    curl -i --header "Content-Type: application/json" \
::          --cookie "urbauth-~zod=0v6.h6t4q.2tkui.oeaqu.nihh9.i0qv6" \
::          --request POST \
::          --data '{"command": "|mount %base"}' \
::          http://localhost:8080/spider/base/json/herald/json
::    ```
::
::    This thread streamlines the process of external apps installing software,
::    issuing pokes to other ships on the network, evaluating and retrieving
::    the return value of arbitrary Hoon code, and exposing the full
::    functionality of the Urbit ship through the Airlock and Urbit Visor.
::
/-  spider
/+  strandio
=,  strand=strand:spider
^-  thread:spider
=<
|=  arg=vase
=/  m  (strand ,vase)
^-  form:m
::
~&  >  "%herald:  starting thread"
::  1. Extract command from JSON.
=/  =json  (need !<((unit json) arg))
=/  cmd-as-cord  (extract-command json)
?~  cmd-as-cord  !!
=/  cmd  (trip +:cmd-as-cord)
::  2. Send command to Dojo via child thread.
~&  >  "%herald:  dispatching command '{cmd}' to %page"
;<  =bowl:spider  bind:m  get-bowl:strandio
=/  tid  `@ta`(cat 3 'strand_' (scot %uv (sham %page eny.bowl)))
;<  ~  bind:m  (watch-our:strandio /awaiting/[tid] %spider /thread-result/[tid])
;<  ~  bind:m  %-  poke-our:strandio
  :*  %spider
      %spider-start
      !>([`tid.bowl `tid byk.bowl %page !>(`cmd)])
  ==
;<  =cage  bind:m  (take-fact:strandio /awaiting/[tid])
;<  ~      bind:m  (take-kick:strandio /awaiting/[tid])
::  3. Parse response into JSON and return as thread response.
?+  p.cage  ~|([%strange-thread-result p.cage %page tid] !!)
  %thread-done  (pure:m q.cage)
  %thread-fail  (strand-fail:strandio !<([term tang] q.cage))
==
::
::  Helper core
::
|%
::  Reparser for JSON input.
++  extract-command
  %-  ot:dejs-soft:format
  :~  [%json so:dejs-soft:format]
  ==
--
