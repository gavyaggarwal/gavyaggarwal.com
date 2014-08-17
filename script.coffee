$ ->
  console.log "gavyaggarwal.com Loaded"
  do loadEditor
  do setupButtons
  do setupScroller
  do setupContactForm

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
  $("#up-button").click ->
    $('html,body').animate
      scrollTop: 0
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

setupContactForm = ->
  $("#contactmessage").keyup ->
    this.style.height = '1px'
    this.style.height = (40 + this.scrollHeight) + 'px'
  $("#submitform").click ->
    form = $("form")
    name    = do $(form).find("input[name=name]").val
    email   = do $(form).find("input[name=email]").val
    subject = do $(form).find("input[name=subject]").val
    message = do $(form).find("input[name=message]").val
    if name is "" or email is "" or subject is "" or message is ""
      console.log "Invalid Form Data"
      span = $(this).find("span")

      $(span).transition
        x:'20px'
        70
        'ease'
      $(span).transition
        x:'-20px'
        140
        'ease'
      $(span).transition
        x:'20px'
        140
        'ease'
      $(span).transition
        x:'-20px'
        140
        'ease'
      $(span).transition
        x:'0px'
        70
        'ease'
    else
      formData = do $(form).serialize
      status = $("#contactstatus")
      formError = ->
        $(status).html "Something went wrong! Just shoot me an <a href='mailto:gavyaggarwal@gmail.com'>email</a> instead."
        $(status).css
          opacity:1
        console.log "Error Submitting Contact Form"
      formSuccess = ->
        $(status).html "Thanks for getting in touch. I'll get back to you soon!"
        $(status).css
          opacity:1
        $(form).find("input[type=text], textarea").val ""
        console.log "Contact Form Submitted Successfully"
      formSubmitted = ->
        $(status).html "Loading"
        $(status).css
          opacity:1
      $.ajax
        url: "http://bin.gavyaggarwal.com/mailer?" + formData
        success: (data) ->
          if data is "success"
            do formSuccess
          else
            do formError
        error: ->
          do formError
      do formSubmitted
