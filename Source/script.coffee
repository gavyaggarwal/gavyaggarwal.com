$ ->
  console.log "gavyaggarwal.com Loaded"
  do loadEditor
  do setupButtons
  do setupScroller
  do setupContactForm
  do setupHashes
  do setupAnalytics
  do monitorStatus

loadEditor = ->
  request1 = $.ajax("Source/index.jade")
  request1.done ->
    typeCode request1.responseText, "#pane1"
  request2 = $.ajax("Source/style.less")
  request2.done ->
    typeCode request2.responseText, "#pane2"

typeCode = (code, pane) ->
  lines = code.split "\n"
  finished = ->
    console.log "Finished Typing Code (#{pane})"
    sendEvent 'editor', 'finished typing', pane
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
    sendEvent 'navigation', 'click', 'down button'
    $('html,body').animate
       scrollTop:$("#panel2").offset().top
       1000
    return false
  $("#up-button").click ->
    sendEvent 'navigation', 'click', 'up button'
    $('html,body').animate
      scrollTop: 0
      1000
    return false



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
  offsetLeft =  $($('.slider-content')[scrollerCurrentPage]).offset().left
  $('#viewport').animate
    scrollLeft: '+=' + offsetLeft
    1000
  dots = $(".dot")
  $(dots).removeClass("selected")
  $(dots[scrollerCurrentPage]).addClass("selected")

  do changeSliderColor
  content = $($('.slider-content')[scrollerCurrentPage]).attr 'id'
  sendEvent 'projects', 'loaded', content

changeSliderColor = ->
  panel = $ '#panel2'
  slider = panel.find '#slider'
  content = slider.find('.slider-content')[scrollerCurrentPage]
  arrows = slider.find '#left,#right'
  dots = slider.find '.dot'

  color = $(content).css('color')
  panel.css
    color:color
    borderTopColor:color
    borderBottomColor:color
  arrows.css
    background:color
  dots.css
    backgroundColor:color

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
      sendEvent 'contact', 'submit', 'invalid data'
    else
      formData = do $(form).serialize
      status = $("#contactstatus")
      formError = ->
        $(status).html "Something went wrong! Just shoot me an
        <a href='mailto:gavyaggarwal@gmail.com'>email</a> instead."
        $(status).css
          opacity:1
        console.log "Error Submitting Contact Form"
        sendEvent 'contact', 'submit', 'error'
      formSuccess = ->
        $(status).html "Thanks for getting in touch. I'll get back to you soon!"
        $(status).css
          opacity:1
        $(form).find("input[type=text], textarea").val ""
        console.log "Contact Form Submitted Successfully"
        sendEvent 'contact', 'submit', 'success'
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
      sendEvent 'contact', 'submit', 'sending request to bin'
      do formSubmitted

setupHashes = ->
  onScroll = ->
    $('.anchor').each ->
      elemTop = $(this).offset().top
      elemHeight = $(this).parent().height()
      winTop = window.pageYOffset
      if elemTop < winTop + 10 and (elemTop + elemHeight) > winTop + 10
        initialHash = window.location.hash
        window.location.hash = '#' + $(this).attr 'id'
        $(document).scrollTop winTop #Prevents Scrolling
        if window.location.hash isnt initialHash
          console.log "Page Changed to #{window.location.hash}"
  $(document).bind 'scroll', onScroll

setupAnalytics = ->
  ((i, s, o, g, r, a, m) ->
    i["GoogleAnalyticsObject"] = r
    i[r] = i[r] or ->
      (i[r].q = i[r].q or []).push arguments
      return

    i[r].l = 1 * new Date()

    a = s.createElement(o)
    m = s.getElementsByTagName(o)[0]

    a.async = 1
    a.src = g
    m.parentNode.insertBefore a, m
    return
  ) window, document, "script", "//www.google-analytics.com/analytics.js", "ga"

  #Only the production version should have www in the URL
  isDev = not ~window.location.href.indexOf 'www'
  if isDev then console.log 'Development Version' else console.log 'Production Version'
  trackingID = if isDev then 'UA-54102576-1' else 'UA-54102576-2'
  ga 'create', trackingID,
    alwaysSendReferrer:yes
  ga 'require', 'displayfeatures'
  ga 'require', 'linkid'
  ga 'send', 'pageview'

  headings = $ '#panel1 #items h3'
  headings.mouseover ->
    text = $(this).html()
    sendEvent 'headers', 'hover', text

  fields = $ '#panel4 form input,textarea'
  fields.focus ->
    text = $(this).attr('placeholder')
    sendEvent 'contact', 'focus', text

  links = $ '#panel4 .box'
  links.click ->
    text = $(this).find('span').html()
    sendEvent 'social links', 'click', text

sendPageView = (page) ->
  ga 'send', 'pageview',
    'page':page

sendEvent = (category, action, label, value) ->
  ga 'send', 'event', category, action, label, value



siteOnline = yes
monitorStatus = ->
  callback = (status) ->
    if status.valueOf() is 'offline'.valueOf()
      do deletePage if siteOnline
    else
      do restorePage if not siteOnline
  authenticate = ->
    $.get 'http://bin.gavyaggarwal.com/gavyaggarwal-status', callback
  do authenticate
  setInterval authenticate, 3000

deletePage = ->
  siteOnline = no
  console.log 'Bye Guys! This site is going down!'
  container = $ '#panel1 #content'
  do container.empty
  container.html '<h4>This website is temporarily unavailable.</h4>
  <h4>Please try again in a bit.</h4>'
  do $('#background').empty
  do $('#panel2').remove
  do $('#panel3').remove
  do $('#panel4').remove
  do $('#panel5').remove
  sendEvent 'page status', 'disabled'

restorePage = ->
  siteOnline = yes
  #Alternate method of sending analytics with callback
  callback = ->
    console.log 'Annnd, we\'re back up!'
    do location.reload
  ga 'send',
    'hitCallback': callback
    'hitType': 'event'
    'eventCategory': 'page status'
    'eventAction': 'enabled'
