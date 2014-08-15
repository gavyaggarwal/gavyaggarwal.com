$ ->
  console.log "gavyaggarwal.com Loaded"
  loadEditor()

loadEditor = () ->
  request = $.ajax("index.jade")
  request.done ->
    parseCode request.responseText

parseCode = (code) ->
  lines = code.split "\n"
  typeLine lines, 0

typeLine = (code, line) ->
  text = code[line]
  typeBuffer text, false, false, false
  $('#pane1').append '<br />'
  typeBuffer code[1]
  $('#pane1').append '<br />'
  typeBuffer code[2]
  $('#pane1').append '<br />'
  typeBuffer code[3]
  $('#pane1').append '<br />'
  typeBuffer code[4]
  $('#pane1').append '<br />'
  typeBuffer code[5]
  $('#pane1').append '<br />'
  typeBuffer code[6]
  $('#pane1').append '<br />'
  typeBuffer code[7]

typeBuffer = (buffer, hadSpace, inBrackets, inQuotes, callback) ->
  arr = [0..buffer.length]
  for i of arr
    char = buffer.charAt i
    if !hadSpace
      hadSpace = (char==" ")
    if inBrackets
      inBrackets = !(char==")")
    else
      inBrackets = (char=="(")
    if char=="'"
      inQuotes = !inQuotes
    color = if hadSpace then "#DBDDDE" else "#FFCD02"
    color = "#34AADC" if inBrackets
    color = "#FF3B30" if inQuotes
    color = "#DBDDDE" if (char=="(") or (char==")") or (char=="=") or (char==",")
    color = "#FF3B30" if (char=="'")
    element = createElement char, color
    $('#pane1').append element
    console.log element

createElement = (char, color) ->
  span = '<span style="color: ' + color + ';">' + char + '</span>'
