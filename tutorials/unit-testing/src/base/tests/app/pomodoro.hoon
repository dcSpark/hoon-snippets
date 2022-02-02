::  Demonstrate unit testing on a Gall agent with %pomodoro.
::
/+  *test
/=  agent  /app/pomodoro
|%
::  Build an example bowl manually.
::
++  bowl
  |=  run=@ud
  ^-  bowl:gall
  :*  [~zod ~zod %pomodoro]     :: (our src dap)
      [~ ~]                     :: (wex sup)
      [run `@uvJ`(shax run) *time [~zod %base ud+run]]
                                :: (act eny now byk)
  ==
::  Build a reference state mold.
::
+$  state
  $:  %0
      watchers=(set @p)
      status=?(%work %break)
  ==
--
|%
::  Test adding a watcher to the list.
::
++  test-add-client
  =|  run=@ud 
  =^  move  agent  (~(on-poke agent (bowl run)) %pomodoro-action !>([%add-client ~zod]))
  =+  !<(=state on-save:agent)
  %+  expect-eq
    !>  [%0 watchers={~zod} status=%break]
    !>  watchers.state
  ==
--
