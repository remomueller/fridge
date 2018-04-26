@facesReady = ->
  $(".cube-faces").sortable(
    axis: "y"
    forcePlaceholderSize: true
    handle: ".face-id"
    placeholder: "face-wrapper-placeholder"
    stop: (event, ui) ->
      console.log "facesReady() -> stop -> face.cube.updateFacePositions"
      cube = new Cube(ui.item[0])
      cube.updateFacePositions()
  )

@destroyFace = (face) ->
  console.log "destroyFace(face)"
  face.destroyed = "true"
  if !!face.id
    params = {}
    params._method = "delete"
    url = "#{face.url}/#{face.id}"
    $.post(
      url
      params
      null
      "json"
    )

@removeFace = (face) ->
  return unless face.text == ""
  position = face.position - 1 # Needs to be stored before face is destroyed/removed.
  cube = face.cube
  destroyFace(face)
  face.removeFromDOM()
  cube.updateFacePositions(position) # Needs to be done after cube is removed from DOM
  cube.saveFacePositions()

@facePrevAndDelete = (face) ->
  face.destroyed = "true" # Make sure face isn't saved on input blur.
  faceSetFocusEnd(face.prevFace)
  removeFace(face) if face.text == ""

@faceNextAndDelete = (face) ->
  face.destroyed = "true" # Make sure face isn't saved on input blur.
  faceSetFocusStart(face.nextFace)
  removeFace(face) if face.text == ""

@faceNext = (element) -> # TODO: Remove this function
  face = new Face(element)
  faceSetFocusEnd(face.nextFace)

@faceChildFirst = (cube) ->
  face = cube.faces[0]
  setFocusEnd(face.input) if face && face.input

@faceChildLast = (cube) ->
  face = cube.faces[cube.faces.length - 1]
  setFocusEnd(face.input) if face && face.input

@faceSetFocusEnd = (face) -> # Could be refactored to work for cubes and faces
  setFocusEnd(face.input) if face && face.input

@faceSetFocusStart = (face) -> # Could be refactored to work for cubes and faces
  setFocusStart(face.input) if face && face.input

$(document)
  .on("keydown", "[data-object=face-wrapper] .face-input", (e) ->
    that = this # TODO: event.target
    tray = new Tray
    thisFace = new Face(that)
    prevFace = thisFace.prevFace
    nextFace = thisFace.nextFace
    document.getElementById("output").textContent = event.which
    if e.which == 13
      if thisFace.text == "" && !nextFace
        thisFace.destroyed = "true" if prevFace # TODO: Needs to actually be destroyed as well if it already exists.
        tray.appendCube(that)
        cubeNext(that)
        removeFace(thisFace) if prevFace
      else
        thisFace.cube.appendFace(that)
        faceNext(that)
      e.preventDefault()
    else if e.which == 8 && prevFace && getCursorPosition(that) == 0 && nothingSelected(that) && thisFace.text == ""
      facePrevAndDelete(thisFace)
      e.preventDefault()
    else if e.which == 46 && nextFace && getCursorPosition(that) == 0 && nothingSelected(that) && thisFace.text == ""
      faceNextAndDelete(thisFace)
      e.preventDefault()
    else if e.which == 38
      if prevFace
        faceSetFocusEnd(prevFace)
      else
        cubeSetFocusEnd(thisFace.cube)
      e.preventDefault()
    else if e.which == 40 && nextFace
      faceSetFocusEnd(nextFace)
      e.preventDefault()
    else if e.which == 40 && thisFace.cube.nextCube
      cubeSetFocusEnd(thisFace.cube.nextCube)
    else if e.which == 66 && e.metaKey
      boldSelection(that)
      e.preventDefault()
  )
  .on("keyup", "[data-object=face-wrapper] .face-input", (e) ->
    face = new Face(this)
    face.redrawText()
  )
  .on("blur", "[data-object=face-wrapper] .face-input", (e) ->
    face = new Face(this)
    face.save("blur")
  )
