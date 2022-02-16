/-  gs=graph-store, gspost=post
/+  *chatbot, default-agent, dbug, graph, gslib=graph-store, sig=signatures
|%
+$  versioned-state
  $%  state-0
  ==
::
+$  state-0
  $:  [%0 count=@]
  ==
::
+$  card  card:agent:gall
::
--
%-  agent:dbug
=|  state-0
=*  state  -
^-  agent:gall
=<
|_  =bowl:gall
+*  this      .
    default   ~(. (default-agent this %|) bowl)
    hc      ~(. +> bowl)
::
++  on-init
  ^-  (quip card _this)
  ~&  >  'dcSpark %chatbot launched'
  =.  state  [%0 count=0]
  [~[(subscribe:hc)] this]
++  on-save
  ^-  vase
  !>(state)
++  on-load
  |=  old-state=vase
  ^-  (quip card _this)
  ~&  >  'dcSpark chatbot reloaded'
  =/  prev  !<(versioned-state old-state)
  ?-  -.prev
    %0
    `this(state prev)
  ==
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?+    mark   ~&  (help-message:hc)  `this
      %noun  `this
  ==
++  on-arvo   on-arvo:default
++  on-watch  on-watch:default
++  on-leave  on-leave:default
++  on-peek   on-peek:default
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ?+    wire  (on-agent:default wire sign)
    [%dcspark-chatbot *]
    ?-  -.sign
      %watch-ack
        ~&  >   "subscribed on wire {<wire>} successfully"
        `this
      %fact  
        =/  incoming-post  (parse-incoming:hc cage.sign)
        ?~  incoming-post  `this
        =/  post  (need incoming-post)
        =/  reaction  (get-reaction:hc post)
        ?~  reaction  `this
        =/  reply-card  (build-poke:hc (need reaction) resource.post)
        [[reply-card ~] this(count +(count))]
      %poke-ack
        ~&  >  "poke acked on {<wire>} successfully"
        `this
      %kick
        ~&  >  "kicked from subscription {<wire>}"
        ~&  >  "resubscribing"
        [~[(subscribe:hc)] this]
    ==
  ==
++  on-fail   on-fail:default
--
|_  =bowl:gall
++  subscribe
  |. 
  ^-  card
  =/  task  `task:agent:gall`[%watch /updates]
  ~&  >  "building subscription"
  =/  ship  `[@p @tas]`[our.bowl %graph-store]
  =/  note  `note:agent:gall`[%agent ship task]
  =/  wire  `wire`/dcspark-chatbot/(scot %p our:bowl)/(scot %da now:bowl)
  =/  card  `card`[%pass wire note]
  card
++  parse-incoming
  |=  =cage
  ^-  (unit parsed)
  =/  incoming-post=(unit parsed)  
  %-  extract-post  %-  update-from-cage  cage
  ?~  incoming-post  ~
  =/  post  (need incoming-post)
  ~&  >>>  post
  ?~  index.post  ~
  `post
++  get-reaction
  |=  post=parsed
  ^-  (unit content:gspost)
  =/  reply-content  (extract-first-text contents.post)
  ?~  reply-content  ~
  (react (need reply-content))
++  build-poke
  |=  [reaction=content:gspost =resource]
  ^-  card:agent:gall
  =/  reply-post  (build-post reaction now.bowl our.bowl)
  =/  reply-node  (build-node reply-post)
  =/  reply-action  (build-action reply-node resource)
  =/  reply-update  (build-update reply-action now.bowl)
  (build-graph-store-poke-card reply-update resource now.bowl our.bowl)
++  react
  |=  text=@t
  ^-  (unit content:gspost)
  ?:  =('.' text)  `[%text text='ack']
  ?:  =('!dcbot ascii' text)  `[%text text=(ascii-logo)]
  ?:  =('!dcbot website' text)  `[%url url='https://dcspark.io']
  ?:  =('!dcbot visor' text)  `[%url url='https://urbitvisor.com']
  ?:  =('!dcbot dashboard' text)  `[%url url='https://urbitdashboard.com']
  ?:  =('!dcbot flint' text)  `[%url url='https://twitter.com/FlintWallet']
  ?:  =('!dcbot milkomeda' text)  `[%url url='https://milkomeda.com']
  ?:  =('!dcbot discord' text)  `[%url url='https://discord.gg/qTYtGs2hq4']
  ?:  =('!dcbot snippets' text)  `[%url url='https://github.com/dcspark/hoon-snippets']
  ?:  =('!dcbot sourcecode' text)  `[%url url='https://github.com/dcspark/hoon-snippets/agents/chatbot']
  ?:  =('!dcbot visorvids' text)  `[%url url='https://www.youtube.com/watch?v=DquwDSPZSvs&list=PLr8CYRYebz4DP7HyihTZWYUQ3x6BWIZR_']
  ?:  =('!dcbot help' text)  `[%text text=(help-message)]
  ?:  =('!dcbot' text)  `[%text text=(help-message)]  ~
++  help-message
|.
'''
dcSpark Chatbot Command List:
`!dcbot website`    -> The dcSpark Website
`!dcbot visor`      -> The Urbit Visor Website
`!dcbot visorvids   -> Getting Started With Urbit Visor
`!dcbot dashboard`  -> The Urbit Dashboard Website
`!dcbot flint`      -> The Flint Wallet Website
`!dcbot milkomeda`  -> The Milkomeda Website
`!dcbot discord`    -> The dcSpark Discord
`!dcbot snippets`   -> The dcSpark Hoon Snippets Github Repo
`!dcbot sourcecode` -> The source code of yours truly
`.` -> Your dot will be acked automatically
'''
++  ascii-logo
|.
'''
```
                &&&&&&&&&               
                &&&&&&&&&               
                &&&&&&&&&               
                &&&&&&&&&               
    &&          &&&&&&&&&          //   
  &&&&&&&&&     &&&&&&&&&     ///////// 
 &&&&&&&&&&&&&&&&&&&&&&&&///////////////
  &&&&&&&&&&&&&&&&&&&&&&&////////////// 
        &&&&&&&&&&&&&&&&&////////       
        &&&&&&&&&&&&&&&&&////////       
   &&&&&&&&&&&&&&&&&&&////////////////  
 &&&&&&&&&&&&&&&&       ////////////////
  &&&&&&&&&&                 ////////// 
   &&&                             ///  
```
'''
--