"use strict";

function setFocusEnd(element) {
  var length = element.value.length;
  element.focus();
  element.setSelectionRange(length, length);
}

function setFocusStart(element) {
  element.focus();
  element.setSelectionRange(0, 0);
}
