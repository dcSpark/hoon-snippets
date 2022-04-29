:: dcSpark
:: document editor

:: imports

/+  default-agent

:: structures

|%
+$  document
  $:  lines=(list line)
      permissions=[admins=(set ship) authors=(set ship) readers=(set ship)]
      title=@t
      time=@da
      author=(set @p)
  ==
+$  line
  $:  id=@
      text=@t
      comments=(list comment)
  ==
+$  comment
  $:  author=@p
      text=@t
  ==
--

:: logic
:: interface

=|  document
=*  state  -
^-  agent:gall
=<
|_  =bowl:gall
+*  this  .
    def   ~(. (default-agent this %|) bowl)
    logic-core  ~(. +> bowl)
::
++  on-init   on-init:def
++  on-save   !>(state)
++  on-load
  |=  old=vase
  ^-  (quip card _this)
  [~ this]
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  =^  cards  state
  ?+  mark   (on-poke:def mark vase)
    %add-line  (add-line:logic-core !<([@ @t] vase))
    %modify-line  (modify-line:logic-core !<([@ @t] vase))
  ==
  [cards this]

++  on-watch  on-watch:def
++  on-leave  on-leave:def
++  on-peek   on-peek:def
++  on-agent  on-agent:def
++  on-arvo   on-arvo:def
++  on-fail   on-fail:def
--
|_  =bowl:gall
++  add-line
  |=  [id=@ text=@t]
  ^-  (quip card _state)
  =.  lines.state  (snoc lines.state =>  *line  .(id id, text text))
  [~ state]
++  modify-line
  |=  [id=@ text=@t]
  ^-  (quip card _state)
  =/  current  (snag id lines.state)
  ?.  =(text:current text)  [~ state]
  =.  lines.state  (snap lines.state id current(text text))
  [~ state]
--