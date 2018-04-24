@cubePasteEvent = (e) ->
  tray = new Tray

  pastedText = undefined
  $element = $(e.target);

  if (window.clipboardData && window.clipboardData.getData) # IE
    pastedText = window.clipboardData.getData("Text")
  else
    clipboardData = (e.originalEvent || e).clipboardData
    pastedText = clipboardData.getData("text/plain") if (clipboardData && clipboardData.getData)

  selection = $element.getSelection()
  if selection
    pos_start = selection.start
    pos_end = selection.end
  else
    pos_start = pos_end = $element.getCursorPosition()

  original_text = $element.val()
  array = pastedText.split("\n").map((x) -> $.trim(x)).filter((x) -> x.length > 0)

  if array.length == 1 || $element.val() == ""
    insertTextAtCursor($element, array.shift())

  nextElement = $element[0]
  multiline = false
  facePosition = 0
  $.each(array, (index, text) ->
    currentElement = nextElement
    if text[0] == "-"
      cube = new Cube(nextElement)
      if facePosition == 0
        cube.cubeType = "choice"
        cube.redrawCubeType()
      facePosition += 1
      appendNewFaceToCubeWrapper(cube.wrapper, facePosition, $.trim(text.slice(1)))
    else
      nextElement = tray.appendCube(nextElement, text)
      facePosition = 0
    multiline = true
    # Save last cube if facePosition == 0
    if facePosition == 0
      cube = new Cube(currentElement)
      cube.save("paste")
  )
  if multiline
    # Save last cube
    cube = new Cube(nextElement)
    cube.save("paste")
    setFocusEnd($(nextElement).find(".cube-input")) # TODO: Refactor using cube
    facesReady()
  e.preventDefault()
