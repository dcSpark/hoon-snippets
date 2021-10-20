  ::  camel.hoon
::::
::    A library for basic camel-case and kebab-case interconversions convenient
::    to Javascript users.
::
::    > A term has an aura of @tas, and is a subset of a knot. It only allows
::      lower-case letters, numbers, and hyphens.
::
|%
::  Single-character checks and conversions
::
++  is-lower  |=  c=@t  ^-  ?(%.y %.n)  &((gte c 97) (lte c 122))
++  is-upper  |=  c=@t  ^-  ?(%.y %.n)  &((gte c 65) (lte c 90))
++  is-alpha  |=  c=@t  ^-  ?(%.y %.n)  |((is-upper c) (is-lower c))
++  is-digit  |=  c=@t  ^-  ?(%.y %.n)  &((gte c 48) (lte c 57))
++  is-alnum  |=  c=@t  ^-  ?(%.y %.n)  |((is-alpha c) (is-digit c))
++  is-space  |=  c=@t  ^-  ?(%.y %.n)  =(`@ud`c 32)
++  is-hep    |=  c=@t  ^-  ?(%.y %.n)  =(`@ud`c 45)
++  is-white  |=  c=@t  ^-  ?(%.y %.n)  |((is-space c) =(`@ud`c 13))
++  to-lower  |=  c=@t  ^-  @t  ?:  (is-upper c)  `@t`(add c 32)  c
++  to-upper  |=  c=@t  ^-  @t  ?:  (is-lower c)  `@t`(sub c 32)  c
::  Convert a @tas term to a camel-case tape.  Remove `-` and upper-case
::  immediately subsequent letters.
::
::  E.g., %this-is-an-example becomes "thisIsAnExample"
::
++  kebab-to-camel
  |=  in-tas=@tas
  ^-  tape
  =/  in  (trip in-tas)
  =/  index  0
  =/  count  (lent in)
  =/  out  *tape
  |-  ^-  tape
  ?:  =(index count)  out
  =/  c  (snag index in)
  :: lower case as normal
  ?:  (is-lower c)  $(index +(index), out (weld out `tape`~[c]))
  :: digit as normal
  ?:  (is-digit c)  $(index +(index), out (weld out `tape`~[c]))
  :: trailing hep should be ignored
  ?:  &((is-hep c) =(index (dec count)))  $(index +(index))
  :: hep-letter means upper-case
  ?:  (is-hep c)    $(index +(+(index)), out (weld out `tape`~[(to-upper (snag +(index) in))]))
  $(index +(index))
++  k2c  kebab-to-camel
++  camel-to-kebab
  |=  in=tape
  ^-  @tas
  =/  index  0
  =/  count  (lent in)
  =/  out  *tape
  |-  ^-  @tas
  ?:  =(index count)  `@tas`(crip out)
  =/  c  (snag index in)
  :: lower-case as normal
  ?:  (is-lower c)  $(index +(index), out (weld out `tape`~[c]))
  :: digit as normal
  ?:  (is-digit c)  $(index +(index), out (weld out `tape`~[c]))
  :: space as hep (shouldn't happen in variable names tho)
  ?:  (is-space c)  $(index +(index), out (weld out `tape`~['-']))
  :: initial upper-case as lower-case without hep
  ?:  &((is-upper c) =(index 0))  $(index +(index), out (weld out `tape`~[(to-lower c)]))
  :: upper-case as lower-case after hep
  ?:  (is-upper c)  $(index +(index), out (weld out `tape`~['-' (to-lower c)]))
  $(index +(index))
++  c2k  camel-to-kebab
--
