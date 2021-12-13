/-  *resource, gs=graph-store, gspost=post
/+  default-agent, dbug, graph, gslib=graph-store, sig=signatures
|%
+$  card  card:agent:gall
+$  post  [%add-nodes =resource:gs nodes=(map index:gs node:gs)]
+$  parsed  [=resource:gs contents=(list content:gspost) author=ship =time =index:gs]
+$  add-nodes-action  [%add-nodes =resource nodes=(map index:gspost node:gs)]
::
::  parsing incoming graph-store subscription data
++  update-from-cage
  |=  =cage
  ^-  update:gs
  =/  mark  p.cage
  =/  vase  q.cage
  `update:gs`!<(=update:gs vase)
++  action-from-update
  |=  =update:gs
  ^-  (unit add-nodes-action)
  =/  action=action:gs  q.update
  ?+  action  ~
  [%add-nodes *] 
    `action
  ==
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
++  resource-from-action
  |=  =add-nodes-action
  ^-  resource
  resource.add-nodes-action
++  node-from-action
  |=  =add-nodes-action
  ^-  (unit node:gs)
  =/  nodes  nodes.add-nodes-action
  =/  values  ~(val by nodes)
  ?~  values  ~  
  `i.values
++  post-from-node
  |=  =node:gs
  ^-  (unit post:gspost)
  ?:  ?=(%& -.post.node)  :: this checks for maybe-post, i.e. deleted posts
  `+.post.node
  ~
++  index-from-post
  |=  =post:gspost
  ^-  index:gspost
  index.post
++  author-from-post
  |=  =post:gs
  ^-  ship
  author.post
++  contents-from-post
  |=  =post:gs
  ^-  (list content:gspost)
  contents.post
++  time-from-post
  |=  =post:gs
  ^-  time
  time-sent.post
++  extract-first-text
  |=  contents=(list content:gspost)
  ^-  (unit @t)
  ?+  i.-.contents  ~
  [%text *]
    `text.i.-.contents
  ==
::
:: building a graph-store reply poke
++  build-post 
  |=  [reply=content:gspost =time =ship]
  ^-  post:gspost
  =/  author  ship
  =/  index  ~[+(time)]  :: autoincrement to avoid conflict with trigger index
  =/  contents  ~[reply]
  =/  hash  `@ux`(sham [~ author time contents])
  =/  signature  (sign:sig ship time hash)
  [author=author index=index time-sent=time contents=contents hash=(some hash) signatures=(sy signature^~)]
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
  |=  [action=action:gs timestamp=@da]
  ^-  update:gs
  [p=timestamp q=action]
++  build-graph-store-poke-card
    |=  [reply=update:gs =resource =time =ship]
    ^-  card:agent:gall
    =/  cage  `cage`[%graph-update-3 !>(reply)]
    =/  task  `task:agent:gall`[%poke cage]
    =/  ship  
    ?:  .=(ship entity.resource)   :: (team:title probably affects this tooo)
      `[@p @tas]`[ship %graph-store] 
      `[@p @tas]`[ship %graph-push-hook] 
    =/  note  `note:agent:gall`[%agent ship task]
    =/  wire  `wire`/dcspark-chatbot  
    =/  card  `card`[%pass wire note]
    card
--