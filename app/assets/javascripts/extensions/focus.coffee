# Handles focusing cursor in input fields

@insertTextAtCursor = (element, text) ->
  return if document.execCommand("insertText", false, text)
  # Fallback
  selection = $(element).getSelection()
  if selection?
    # console.log "FF fallback"
    original_text = element.value
    new_text = original_text.substring(0, selection.start) + text + original_text.substring(selection.end)
    element.value = new_text
  else
    # console.log "generic fallback"
    element.value = text
