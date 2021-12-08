/-  *resource, gs=graph-store, gspost=post
/+  default-agent, dbug, graph, gslib=graph-store, sig=signatures
|%
+$  add-nodes-action  [%add-nodes =resource nodes=(map index:gspost node:gs)]
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
--