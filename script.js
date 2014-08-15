(function() {
  var createElement, loadEditor, parseCode, typeBuffer, typeLine;

  $(function() {
    console.log("gavyaggarwal.com Loaded");
    return loadEditor();
  });

  loadEditor = function() {
    var request;
    request = $.ajax("index.jade");
    return request.done(function() {
      return parseCode(request.responseText);
    });
  };

  parseCode = function(code) {
    var lines;
    lines = code.split("\n");
    return typeLine(lines, 0);
  };

  typeLine = function(code, line) {
    var text;
    text = code[line];
    typeBuffer(text, false, false, false);
    $('#pane1').append('<br />');
    typeBuffer(code[1]);
    $('#pane1').append('<br />');
    typeBuffer(code[2]);
    $('#pane1').append('<br />');
    typeBuffer(code[3]);
    $('#pane1').append('<br />');
    typeBuffer(code[4]);
    $('#pane1').append('<br />');
    typeBuffer(code[5]);
    $('#pane1').append('<br />');
    typeBuffer(code[6]);
    $('#pane1').append('<br />');
    return typeBuffer(code[7]);
  };

  typeBuffer = function(buffer, hadSpace, inBrackets, inQuotes, callback) {
    var arr, char, color, element, i, _i, _ref, _results, _results1;
    arr = (function() {
      _results = [];
      for (var _i = 0, _ref = buffer.length; 0 <= _ref ? _i <= _ref : _i >= _ref; 0 <= _ref ? _i++ : _i--){ _results.push(_i); }
      return _results;
    }).apply(this);
    _results1 = [];
    for (i in arr) {
      char = buffer.charAt(i);
      if (!hadSpace) {
        hadSpace = char === " ";
      }
      if (inBrackets) {
        inBrackets = !(char === ")");
      } else {
        inBrackets = char === "(";
      }
      if (char === "'") {
        inQuotes = !inQuotes;
      }
      color = hadSpace ? "#DBDDDE" : "#FFCD02";
      if (inBrackets) {
        color = "#34AADC";
      }
      if (inQuotes) {
        color = "#FF3B30";
      }
      if ((char === "(") || (char === ")") || (char === "=") || (char === ",")) {
        color = "#DBDDDE";
      }
      if (char === "'") {
        color = "#FF3B30";
      }
      element = createElement(char, color);
      $('#pane1').append(element);
      _results1.push(console.log(element));
    }
    return _results1;
  };

  createElement = function(char, color) {
    var span;
    return span = '<span style="color: ' + color + ';">' + char + '</span>';
  };

}).call(this);
