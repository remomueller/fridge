@cubePasteEvent = (event) ->
  tray = new Tray

  pastedText = undefined
  element = event.target;

  if (window.clipboardData && window.clipboardData.getData) # IE
    pastedText = window.clipboardData.getData("Text")
  else
    clipboardData = (event.originalEvent || event).clipboardData
    pastedText = clipboardData.getData("text/plain") if (clipboardData && clipboardData.getData)

  original_text = element.value
  array = pastedText.split("\n").map((x) -> x.trim()).filter((x) -> x.length > 0)

  if array.length == 1 || element.value == ""
    insertTextAtCursor(element, array.shift())

  nextElement = element
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
      cube.appendNewFaceToCubeWrapper(text.slice(1).trim(), facePosition)
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
    cube.focusEnd()
  event.preventDefault()
