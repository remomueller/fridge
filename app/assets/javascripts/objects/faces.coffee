@facesReady = (element) ->
  container = if element then $(element).closest(".cube-faces") else $(".cube-faces")
  container.sortable(
    axis: "y"
    forcePlaceholderSize: true
    handle: ".face-id"
    placeholder: "face-wrapper-placeholder"
    stop: (event, ui) ->
      # console.log "facesReady() -> stop -> face.cube.updateFacePositions"
      cube = new Cube(ui.item[0])
      cube.updateFacePositions()
  )

$(document)
  .on("mouseenter", ".face-id:not(.cube-faces.ui-sortable .face-id)", ->
    # If the cube-faces is not yet sortable, make it sortable (just in time sortable).
    facesReady(this)
  )


@faceNext = (element) -> # TODO: Remove this function
  face = new Face(element)
  faceSetFocusEnd(face.nextFace)

@faceSetFocusEnd = (face) -> # Could be refactored to work for cubes and faces
  setFocusEnd(face.input) if face && face.input

@faceSetFocusStart = (face) -> # Could be refactored to work for cubes and faces
  setFocusStart(face.input) if face && face.input
