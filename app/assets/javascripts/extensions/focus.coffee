# Handles focusing cursor in input fields

@setCursorAtStart = (element) ->
  element.setSelectionRange(0, 0)

@insertTextAtCursor = (element, text) ->
  return if document.execCommand("insertText", false, text)
  # Fallback
  selection = $(element).getSelection()
  if selection?
    # console.log "FF fallback"
    original_text = $(element).val()
    new_text = original_text.substring(0, selection.start) + text + original_text.substring(selection.end)
    $(element).val(new_text)
  else
    # console.log "generic fallback"
    $(element).val(text)

@setFocusEnd = (element) ->
  val = $(element).val()
  $(element).focus().val("").val(val)

@setFocusStart = (element) ->
  element.focus()
  setCursorAtStart(element)
