(function() {
  var createElement, loadEditor, scrollToPage, scrollerCurrentPage, scrollerMaxPage, scrollerMinPage, setupButtons, setupScroller, typeBuffer, typeCode, typeLine;

  $(function() {
    console.log("gavyaggarwal.com Loaded");
    loadEditor();
    setupButtons();
    return setupScroller();
  });

  loadEditor = function() {
    var request1, request2;
    request1 = $.ajax("index.jade");
    request1.done(function() {
      return typeCode(request1.responseText, "#pane1");
    });
    request2 = $.ajax("style.less");
    return request2.done(function() {
      return typeCode(request2.responseText, "#pane2");
    });
  };

  typeCode = function(code, pane) {
    var finished, lines;
    lines = code.split("\n");
    finished = function() {
      return console.log("Finished Typing Code");
    };
    return typeLine(lines, finished, pane, 0);
  };

  typeLine = function(code, callback, pane, line) {
    var finishedLine, text;
    if (line === code.length) {
      return callback();
    } else {
      text = code[line];
      finishedLine = function() {
        $(pane).append('<br />');
        return typeLine(code, callback, pane, line + 1);
      };
      return typeBuffer(text, finishedLine, pane, 0);
    }
  };

  typeBuffer = function(buffer, callback, pane, index, isSecondWord, inBrackets, inQuotes, hadFirstSpace) {
    var char, color, element, timerDone;
    if (index === buffer.length) {
      return callback();
    } else {
      char = buffer.charAt(index);
      if (!hadFirstSpace) {
        if (char !== " ") {
          hadFirstSpace = true;
        }
      } else {
        if (char === " ") {
          isSecondWord = true;
        }
      }
      if (inBrackets) {
        inBrackets = !(char === ")");
      } else {
        inBrackets = char === "(";
      }
      if (char === "'") {
        inQuotes = !inQuotes;
      }
      if (!hadFirstSpace) {
        char = "&emsp;&emsp;";
      }
      color = isSecondWord ? "#DBDDDE" : "#FFCD02";
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
      $(pane).append(element);
      timerDone = function() {
        return typeBuffer(buffer, callback, pane, index + 1, isSecondWord, inBrackets, inQuotes, hadFirstSpace);
      };
      return setTimeout(timerDone, 100);
    }
  };

  createElement = function(char, color) {
    var span;
    return span = '<span style="color: ' + color + ';">' + char + '</span>';
  };

  setupButtons = function() {
    return $("#down-button").click(function() {
      return $('html,body').animate({
        scrollTop: $("#panel2").offset().top
      }, 1000);
    });
  };

  scrollerCurrentPage = 0;

  scrollerMinPage = 0;

  scrollerMaxPage = 0;

  setupScroller = function() {
    var dot, dots, i, length, selectedClass, _i;
    length = $(".slider-content").length;
    scrollerCurrentPage = 0;
    scrollerMinPage = 0;
    scrollerMaxPage = length - 1;
    dots = $("#dots");
    for (i = _i = 0; 0 <= length ? _i < length : _i > length; i = 0 <= length ? ++_i : --_i) {
      selectedClass = i === 0 ? " selected" : "";
      dot = '<div class="dot' + selectedClass + '"></div>';
      $(dots).append(dot);
      $(dot).addClass('selected');
    }
    $("#left").click(function() {
      scrollerCurrentPage--;
      return scrollToPage();
    });
    $("#right").click(function() {
      scrollerCurrentPage++;
      return scrollToPage();
    });
    $(".dot").click(function() {
      scrollerCurrentPage = $(this).index();
      return scrollToPage();
    });
    return scrollToPage();
  };

  scrollToPage = function() {
    var dots;
    $("#left").css({
      opacity: scrollerCurrentPage <= scrollerMinPage ? 0 : ''
    });
    $("#right").css({
      opacity: scrollerCurrentPage >= scrollerMaxPage ? 0 : ''
    });
    if (scrollerCurrentPage < scrollerMinPage) {
      scrollerCurrentPage = scrollerMinPage;
    }
    if (scrollerCurrentPage > scrollerMaxPage) {
      scrollerCurrentPage = scrollerMaxPage;
    }
    $('#viewport').animate({
      scrollLeft: ($('.slider-content').width() + 120) * scrollerCurrentPage
    }, 1000);
    dots = $(".dot");
    $(dots).removeClass("selected");
    return $(dots[scrollerCurrentPage]).addClass("selected");
  };

}).call(this);
