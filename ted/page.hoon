  ::
::::  page.hoon
::
::      Spider thread to execute a single Dojo command.  Intended for use with
::      %herald.
::
/-  spider
/+  strandio
=,  strand=strand:spider
^-  thread:spider
=<
|=  arg=vase
=/  m  (strand ,vase)
^-  form:m
~&  >>  "%page:  starting child thread"
=+  !<([~ cmd=tape] arg)
~&  >>  "%page:  executing command '{cmd}'"
;<  ~  bind:m  (send-raw-cards:strandio (dojo cmd))
(pure:m !>(~))
|%
::  Send command to Dojo as a series of events.
++  dojo
  |=  [=tape]
  ^-  (list =card:agent:gall)
  :~
    [%pass [%belt %$ ~] %arvo %d %belt %ctl `@c`%e]
    [%pass [%belt %$ ~] %arvo %d %belt %ctl `@c`%u]
    [%pass [%belt %$ ~] %arvo %d %belt %txt ((list @c) tape)]
    [%pass [%belt %$ ~] %arvo %d %belt %ret ~]
  ==
--
