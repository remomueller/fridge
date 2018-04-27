function boldSelection(element) {
  var start = element.selectionStart;
  var end = element.selectionEnd;
  var length = end - start;
  var text = element.value.substr(start, length);

  if (text.trim()) {
    var padding_start = (text[0] == " ");
    var padding_end = (text[text.length - 1] == " ");
    var substitute = "";
    if (padding_start) substitute += " ";
    substitute += "**";
    substitute += text.trim();
    substitute += "**";
    if (padding_end) substitute += " ";
    insertTextAtCursor(element, substitute, start + substitute.length);
  }
}

function nothingSelected(element) {
  var start = element.selectionStart;
  var end = element.selectionEnd;
  return start === end;
}
