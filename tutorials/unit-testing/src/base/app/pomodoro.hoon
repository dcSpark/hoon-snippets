/-  pomodoro
/+  default-agent, dbug
|%
+$  versioned-state
  $%  state-0
  ==
+$  status  ?(%work %break)
+$  watchers  (set @p)
+$  state-0
    $:  [%0 =watchers =status]
    ==
+$  card  card:agent:gall
--
::
%-  agent:dbug
=|  state-0
=*  state  -
^-  agent:gall
=<
|_  bol=bowl:gall
+*  this  .
    default   ~(. (default-agent this %.n) bol)
    helper    ~(. +> bol)
::
++  on-init
  ^-  (quip card _this)
  =.  state  [%0 *(set @p) *?(%work %break)]
  `this(watchers *(set @p), status *?(%work %break))
::
++  on-save
  ^-  vase
  !>(state)
::
++  on-load
  |=  old-state=vase
  ^-  (quip card _this)
  =/  prev  !<(versioned-state old-state)
  ?-  -.prev
    ::%~  `this(state prev)
    %0  `this(state prev)
  ==
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?+    mark  (on-poke:default mark vase)
      %pomodoro-action
    =^  cards  state
    (handle-action:helper !<(action:pomodoro vase))
    [cards this]
  ==
::
++  on-watch  on-watch:default
::
++  on-leave  on-leave:default
::
++  on-peek   on-peek:default
::
++  on-agent  on-agent:default
::
++  on-arvo
  ^+  on-arvo:*agent:gall
  |=  [=wire =sign-arvo]
  ^-  (quip card _this)
  ~&  >  "%pomodoro:  timer went off!"
  =/  new-state  ?:(=(%work status.state) %break %work)
  =/  next-time  ?:(=(%work status.state) ~s5 ~s25)
  ~&  >>  "%pomodoro:  start {<new-state>} at {<now.bol>}"
  ~&  >>  "%pomodoro:  (not actually) notifying watchers:"
  ~&  >>  "{<watchers.state>}"
  =.  status.state  new-state
  :_  this
  :~  [%give %fact ~[/pomodoro] [%atom !>(status.state)]]
      [%pass /pomodoro %arvo %b %wait (add now.bol next-time)]
  ==
::
++  on-fail   on-fail:default
--
::
|_  bol=bowl:gall
++  handle-action
  |=  =action:pomodoro
  ^-  (quip card _state)
  ?-    -.action
      :: :pomodoro &pomodoro-action [%add-client ~zod]
      %add-client
    ~&  >  "%pomodoro adding ship {<ship.action>}"
    =.  watchers.state  (~(put in watchers.state) ship.action)
    :_  state
    :~  [%give %fact ~[/pomodoro] [%atom !>(watchers.state)]]
    ==
      :: :pomodoro &pomodoro-action [%remove-client ~zod]
      %remove-client
    ~&  >  "%pomodoro removing ship {<ship.action>}"
    =.  watchers.state  (~(del in watchers.state) ship.action)
    :_  state
    :~  [%give %fact ~[/pomodoro] [%atom !>(watchers.state)]]
    ==
      :: :pomodoro &pomodoro-action [%report ~]
      %report
    ~&  >  "%pomodoro has the following clients:"
    ~&  >  watchers.state
    :_  state
    :~  [%give %fact ~[/pomodoro] [%atom !>(watchers.state)]]
    ==
      :: :pomodoro &pomodoro-action [%start-timer ~]
      %start-timer
    ~&  >  "%pomodoro setting timer for {<`@da`(add now.bol ~s25)>}"
    :_  state
    :~  [%give %fact ~[/pomodoro] [%atom !>(%work)]]
        [%pass /pomodoro %arvo %b %wait (add now.bol ~s25)]
    ==
  ==
--