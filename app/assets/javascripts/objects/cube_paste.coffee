@saveFaceNoCallback = (element) ->
  console.log "saveFaceNoCallback()"
  wrapper = faceWrapper(element)
  # return if faceTextUnchanged(wrapper, element)
  return if $(wrapper).data("destroyed")
  params = {}
  params.face = {}
  params.face.position = $(wrapper).attr("data-position")
  params.face.text = $(element).val()


  # url = $(wrapper).data("url")

  cube_wrapper = cubeWrapper(element)
  url = $(cube_wrapper).data("url")
  console.log "url(1): #{url}"
  if $(cube_wrapper).attr("data-cube")?
    url += "/#{$(cube_wrapper).attr("data-cube")}/faces"
  console.log "url(2): #{url}"
  if $(wrapper).attr("data-face")?
    url += "/#{$(wrapper).attr("data-face")}"
    params._method = "patch"

  console.log "url(3): #{url}"

  $.post(
    url
    params
    null
    "json"
  ).done((data) ->
    if data?
      $(wrapper).attr("data-position-original", parseInt(data.position))

      # Set this using an attribute, so that you can search for it using
      # selectors later in saveFacePositions callback.
      $(wrapper).attr("data-face", data.id)
      # $(wrapper).data("face", data.id) # This doesn't work, see above.

      $(wrapper).attr("data-text", data.text)
      $(element).val(data.text)
      redrawFacePosition(wrapper)
      redrawFaceWrapper(wrapper, element)
      # saveFacePositions(cubeWrapper(wrapper))
  ).fail((data) ->
    console.log "fail: #{data}"
  )

@saveCubeNoCallbackPlusFaces = (element, event_type) ->
  cube = new Cube(element)
  return if cube.unchanged()
  return if cube.saving
  return if cube.destroyed
  console.log "saveCubeNoCallbackPlusFaces()"
  cube.saving = "true"
  params = {}
  params.cube = {}
  params.cube.position = cube.position
  params.cube.text = cube.text
  params.cube.cube_type = cube.cube_type
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
          saveFaceNoCallback(face_input)
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
      cube_wrapper = cubeWrapper(nextElement)
      if facePosition == 0
        cube_wrapper.attr("data-cube-type", "choice")
        redrawCubeCubeType(cube_wrapper)
      facePosition += 1
      appendNewFaceToCubeWrapper(cube_wrapper, facePosition, $.trim(text.slice(1)))
    else
      nextElement = tray.appendCube(nextElement, text)
      facePosition = 0
    multiline = true
    if facePosition == 0
      saveCubeNoCallbackPlusFaces(currentElement, "paste")
    # Save last cube if facePosition == 0
  )
  if multiline
    # Save last cube
    saveCubeNoCallbackPlusFaces(nextElement, "paste")
    setFocusEnd($(nextElement).find(".cube-input"))
    facesReady()
  e.preventDefault()
