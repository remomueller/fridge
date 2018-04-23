@saveFace = (element, event_type) ->
  cube = new Cube(element)
  face = new Face(element, cube)
  return if face.unchanged()
  return if face.saving
  return if face.destroyed
  console.log "saveFace()"
  face.saving = "true"
  params = {}
  params.face = {}
  params.face.position = face.position
  params.face.text = face.text

  url = cube.url
  console.log "url(1): #{url}"
  if cube.id?
    url += "/#{cube.id}/faces"
  console.log "url(2): #{url}"
  if face.id?
    url += "/#{face.id}"
    params._method = "patch"
  console.log "url(3): #{url}"

  $.post(
    url
    params
    null
    "json"
  ).done((data) ->
    if data?
      face.positionOriginal = data.position
      face.id = data.id
      face.textOriginal = data.text
      face.text = data.text
      face.saving = "false"
      face.redraw()
      saveFacePositions(cube.wrapper) if event_type == "blur"
  ).fail((data) ->
    face.saving = "false"
    console.log "fail: #{data}"
  )

@saveCube = (element, event_type) ->
  cube = new Cube(element)
  return if cube.unchanged()
  return if cube.saving
  return if cube.destroyed
  console.log "saveCube()"
  cube.saving = "true"
  params = {}
  params.cube = {}
  params.cube.position = cube.position
  params.cube.text = cube.text
  params.cube.cube_type = cube.cubeType
  # console.log params
  url = cube.url
  if cube.id?
    url += "/#{cube.id}"
    params._method = "patch"

  console.log params

  $.post(
    url
    params
    null
    "json"
  ).done((data) ->
    if data?
      cube.positionOriginal = data.position
      cube.id = data.id
      cube.textOriginal = data.text
      cube.text = data.text
      cube.saving = "false"
      cube.redraw()
      if event_type == "blur"
        saveCubePositions()
      if event_type == "paste"
        $.each(faceWrappers(cube.wrapper), (index, face_wrapper) ->
          face_input = $(face_wrapper).find(".face-input")
          saveFace(face_input[0], event_type)
        )
        saveFacePositions(cube.wrapper)
  ).fail((data) ->
    cube.saving = "false"
    console.log "fail: #{data}"
  )

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
    if facePosition == 0
      saveCube(currentElement, "paste")
    # Save last cube if facePosition == 0
  )
  if multiline
    # Save last cube
    saveCube(nextElement, "paste")
    setFocusEnd($(nextElement).find(".cube-input"))
    facesReady()
  e.preventDefault()
