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
