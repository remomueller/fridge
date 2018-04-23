# Handles text manipulation.

@boldSelection = (element) ->
  selection = $(element).getSelection()
  if selection and selection.text != ""
    padding_start = (selection.text[0] == " ")
    padding_end = (selection.text[selection.text.length - 1] == " ")
    substitute = "#{if padding_start then " " else ""}**#{$.trim(selection.text)}**#{if padding_end then " " else ""}"
    insertTextAtCursor(element, substitute)

@nothingSelected = (element) ->
  selection = $(element).getSelection()
  return true if selection == null
  selection.length == 0
