$ ->
  console.log "gavyaggarwal.com Loaded"
  do loadEditor
  do setupButtons
  do setupScroller

loadEditor = ->
  request1 = $.ajax("index.jade")
  request1.done ->
    typeCode request1.responseText, "#pane1"
  request2 = $.ajax("style.less")
  request2.done ->
    typeCode request2.responseText, "#pane2"

typeCode = (code, pane) ->
  lines = code.split "\n"
  finished = ->
    console.log "Finished Typing Code"
  typeLine lines, finished, pane, 0

typeLine = (code, callback, pane, line) ->
  if line is code.length
    do callback
  else
    text = code[line]
    finishedLine = ->
      $(pane).append '<br />'
      typeLine code, callback, pane, line + 1
    typeBuffer text, finishedLine, pane, 0


typeBuffer = (buffer, callback, pane, index, isSecondWord, inBrackets, inQuotes, hadFirstSpace) ->
  if index is buffer.length
    do callback
  else
    char = buffer.charAt index
    if not hadFirstSpace
      if char!=" "
        hadFirstSpace = yes
    else
      if char==" "
        isSecondWord = yes
    if inBrackets
      inBrackets = !(char==")")
    else
      inBrackets = (char=="(")
    if char=="'"
      inQuotes = !inQuotes
    char = "&emsp;&emsp;" if not hadFirstSpace
    color = if isSecondWord then "#DBDDDE" else "#FFCD02"
    color = "#34AADC" if inBrackets
    color = "#FF3B30" if inQuotes
    color = "#DBDDDE" if (char=="(") or (char==")") or (char=="=") or (char==",")
    color = "#FF3B30" if (char=="'")
    element = createElement char, color
    $(pane).append element
    timerDone = ->
      typeBuffer buffer, callback, pane, index + 1, isSecondWord, inBrackets, inQuotes, hadFirstSpace
    setTimeout timerDone, 100

createElement = (char, color) ->
  span = '<span style="color: ' + color + ';">' + char + '</span>'



setupButtons = ->
  $("#down-button").click ->
    $('html,body').animate
       scrollTop: $("#panel2").offset().top
       1000


scrollerCurrentPage = 0
scrollerMinPage = 0
scrollerMaxPage = 0
setupScroller = ->
  length = $(".slider-content").length
  scrollerCurrentPage = 0
  scrollerMinPage = 0
  scrollerMaxPage = length-1
  dots = $("#dots")
  for i in [0...length]
    selectedClass = if i is 0 then " selected" else ""
    dot = '<div class="dot' + selectedClass + '"></div>'
    $(dots).append(dot)
    $(dot).addClass('selected')
  $("#left").click ->
    scrollerCurrentPage--
    do scrollToPage
  $("#right").click ->
    scrollerCurrentPage++
    do scrollToPage
  $(".dot").click ->
    scrollerCurrentPage = $(this).index()
    do scrollToPage
  do scrollToPage

scrollToPage = ->
  $("#left").css
    opacity:if scrollerCurrentPage <= scrollerMinPage then 0 else ''
  $("#right").css
    opacity:if scrollerCurrentPage >= scrollerMaxPage then 0 else ''
  scrollerCurrentPage = scrollerMinPage if scrollerCurrentPage < scrollerMinPage
  scrollerCurrentPage = scrollerMaxPage if scrollerCurrentPage > scrollerMaxPage
  $('#viewport').animate
    scrollLeft:($('.slider-content').width() + 120) * scrollerCurrentPage
    1000
  dots = $(".dot")
  $(dots).removeClass("selected")
  $(dots[scrollerCurrentPage]).addClass("selected")
