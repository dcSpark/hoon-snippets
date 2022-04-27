:: dcSpark
:: document editor

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