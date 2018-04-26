"use strict";

function getCursorPosition(element) {
  var position = 0;
  if ("selectionStart" in element) {
      position = element.selectionStart;
  } else if("selection" in document) {
      element.focus();
      var Sel = document.selection.createRange();
      var SelLength = document.selection.createRange().text.length;
      Sel.moveStart("character", -element.value.length);
      position = Sel.text.length - SelLength;
  }
  return position;
}
