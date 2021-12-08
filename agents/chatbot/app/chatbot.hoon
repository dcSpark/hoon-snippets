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
+$  post  [%add-nodes =resource:gs nodes=(map index:gs node:gs)]
+$  parsed  [=resource:gs contents=(list content:gspost) author=ship =time =index:gs]
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
  ~&  >  'dcSpark Urbit chatbot started'
  =.  state  [%0 count=0]
  [~[(subscribe:hc)] this]
++  on-save
  ^-  vase
  !>(state)
++  on-load
  |=  old-state=vase
  ^-  (quip card _this)
  ~&  >  'dcSpark Urbit chatbot reloaded'
  =/  prev  !<(versioned-state old-state)
  ?-  -.prev
    %0
    `this(state prev)
  ==
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?+    mark  (on-poke:default mark vase)
      %noun
    ?+    q.vase  (on-poke:default mark vase)
        %print-state
      ~&  >>  state
      `this
          ::
      %subscribe
        [~[(subscribe:hc)] this]
      %unsubscribe
        `this
    ==
  ==
++  on-arvo   on-arvo:default
++  on-watch  on-watch:default
++  on-leave  on-leave:default
++  on-peek   on-peek:default
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ?+    wire  (on-agent:default wire sign)
    [%dcspark-chatbot ~]
    ?-  -.sign
      %watch-ack
        `this
      %fact  
      =/  incoming-post=(unit parsed)  
        %-  extract-post  %-  update-from-cage 
        cage.sign
      ?~  incoming-post
        `this
      =/  post  (need incoming-post)
      ?~  index.post  `this
      =/  reply-content  (extract-first-text contents.post)
      ?~  reply-content  `this
      =/  reaction  (react (need reply-content))
      ?~  reaction  `this
      =/  reply-post  (build-post:hc (need reaction))
      =/  reply-node  (build-node:hc reply-post)
      =/  reply-action  (build-action:hc reply-node resource.post)
      =/  reply-update  (build-update:hc reply-action)
      =/  reply-card  (build-poke-card:hc reply-update resource.post)
      [[reply-card ~] this(count +(count))]
      %poke-ack
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
  =/  ship  `[@p @tas]`[our.bowl %graph-store]
  =/  note  `note:agent:gall`[%agent ship task]
  =/  wire  `wire`/dcspark-chatbot
  =/  card  `card`[%pass wire note]
  card
++  build-post
  |=  [reply=content:gspost]
  ^-  post:gspost
  =/  author  our.bowl
  =/  index  ~[+(now.bowl)]  :: increment the index so it doesn't conflict with the index of the trigger node
  =/  time-sent  now.bowl
  =/  contents  ~[reply]
  =/  hash  `@ux`(sham [~ author time-sent contents])
  =/  signature  (sign:sig our.bowl now.bowl hash)
  [author=author index=index time-sent=time-sent contents=contents hash=(some hash) signatures=(sy signature^~)]
++  build-node
  |=  [post=post:gspost]
  ^-  node:gs
  [post=[%& p=post] children=[%empty ~]]
++  build-action
  |=  [node=node:gs =resource]
  ^-  action:gs
  ?>  ?=(%& -.post.node)
  =/  post  `post:gs`+.post.node
  =/  index  index.post
  =/  map  (my ~[[index node]])
  [%add-nodes resource=resource nodes=map]
++  build-update
  |=  [action=action:gs]
  ^-  update:gs
  [p=now.bowl q=action]
++  build-poke-card
    |=  [reply=update:gs =resource]
    ^-  card
    =/  cage  `cage`[%graph-update-3 !>(reply)]
    =/  task  `task:agent:gall`[%poke cage]
    =/  ship  
    ?:  .=(our.bowl entity.resource)
      `[@p @tas]`[our.bowl %graph-store] 
      `[@p @tas]`[our.bowl %graph-push-hook] 
    =/  note  `note:agent:gall`[%agent ship task]
    =/  wire  `wire`/dcspark-chatbot 
    =/  card  `card`[%pass wire note]
    card
++  extract-post
  |=  =update:gs
  ^-  (unit parsed)
  =/  action  (action-from-update update)
  ?~  action  ~
  =/  node  (node-from-action (need action))
  ?~  node  ~
  =/  post  (post-from-node (need node))
  ?~  post  ~
  =/  p  (need post)
  `[resource=(resource-from-action (need action)) contents=(contents-from-post p) author=(author-from-post p) time=(time-from-post p) index=(index-from-post p)]
++  react
  |=  text=@t
  ^-  (unit content:gspost)
  ?:  .=('.' text)  `[%text text='ack']
  ?:  .=('gm' text)  `[%text text='gm!']
  ?:  .=('is zod ok?' text)  `[%text text='probably']
  ?:  .=('!dcbot ascii' text)  `[%text text=(aa-message)]
  ?:  .=('!dcbot website' text)  `[%url url='https://dcspark.io']
  ?:  .=('!dcbot visor' text)  `[%url url='https://urbitvisor.com']
  ?:  .=('!dcbot dashboard' text)  `[%url url='https://urbitdashboard.com']
  ?:  .=('!dcbot flint' text)  `[%url url='https://twitter.com/FlintWallet']
  ?:  .=('!dcbot milkomeda' text)  `[%url url='https://milkomeda.com']
  ?:  .=('!dcbot discord' text)  `[%url url='https://discord.gg/qTYtGs2hq4']
  ?:  .=('!dcbot hoon' text)  `[%url url='https://github.com/dcspark/hoon-snippets']
  ?:  .=('!dcbot bot' text)  `[%url url='https://github.com/dcspark/hoon-snippets/chatbot']
  ?:  .=('!dcbot help' text)  `[%text text=(help-message)]  ~
++  help-message
|.
'''
dcSpark Chatbot Command List:
!dcbot website -> The dcSpark Website
!dcbot visor -> The Urbit Visor Website
!dcbot dashboard -> The Urbit Dashboard Website
!dcbot flint -> The Flint Wallet Website
!dcbot milkomeda -> The Milkomeda Website
!dcbot discord -> The dcSpark Discord
!dcbot snippets -> The dcSpark Hoon Snippets Github Repo
!dcbot sourcecode -> The source code of yours truly
. -> Your dot will be acked automatically
'''
++  aa-message
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