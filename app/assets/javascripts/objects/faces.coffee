@facesReady = ->
  $.each($(".cube-faces"), ->
    $this = $(this)
    $this.sortable(
      axis: "y"
      forcePlaceholderSize: true
      handle: ".face-id"
      placeholder: "face-wrapper-placeholder"
      stop: (event, ui) ->
        wrapper = faceWrappers($this).first()
        if wrapper
          updateFacePosition(wrapper, 1)
          updateFacePositions(wrapper)
    )
  )

@faceWrappers = (element) ->
  $(element).find("[data-object~=face-wrapper]")

@faceWrapper = (element) ->
  wrapper = $(element).closest("[data-object~=face-wrapper]")

@saveFacePositions = (cube_wrapper) ->
  console.log "saveFacePositions()"
  url = ""
  params = {}
  params.faces = {}
  $.each(faceWrappers(cube_wrapper), (index, face_wrapper) ->
    return true if $(face_wrapper).attr("data-position") == $(face_wrapper).attr("data-position-original")
    url = "#{$(face_wrapper).data("url")}/positions"
    params.faces["#{$(face_wrapper).data("face")}"] = (
      "position": $(face_wrapper).attr("data-position")
    )
  )
  # console.log params
  return unless !!url
  $.post(
    url
    params
    null
    "json"
  ).done((data) ->
    if data?
      $.each(data, (index, face) ->
        face_wrapper = $("[data-object~=face-wrapper][data-face=#{face.id}]")
        if $(face_wrapper).length > 0
          $(face_wrapper).attr("data-position-original", parseInt(face.position))
          redrawFacePosition(face_wrapper)
        else
          console.log "NO WRAPPER FOUND for \"#{face.id}\""
      )
      # console.log "saveFacePositions: DONE"
  ).fail((data) ->
    console.log "saveFacePositions: FAIL"
    console.log "#{data}"
  )

@destroyFace = (face) ->
  # console.log "destroyFace"
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
    ).done((data) ->
      # TODO: change how face positions are saved (refactor)
      saveFacePositions(face.cube.wrapper) # Wait for completion
    )
  else
    # TODO: change how face positions are saved (refactor)
    saveFacePositions(face.cube.wrapper) # Always save face positions

@updateFacePositions = (wrapper, position = parseInt($(wrapper).attr("data-position"))) ->
  $.each($(wrapper).nextAll("[data-object=face-wrapper]"), (index, w) ->
    position += 1
    updateFacePosition(w, position)
  )

@updateFacePosition = (wrapper, position) ->
  $(wrapper).attr("data-position", position)
  redrawFacePosition(wrapper)

@redrawFacePosition = (wrapper) ->
  $(wrapper).find(".face-id").html("#{$(wrapper).attr("data-position")}")
  if $(wrapper).attr("data-position") != $(wrapper).attr("data-position-original")
    $(wrapper).addClass("face-wrapper-unsaved-position")
  else
    $(wrapper).removeClass("face-wrapper-unsaved-position")

@removeFace = (face) ->
  return unless face.text == ""
  updateFacePositions(face.wrapper, face.position - 1)
  destroyFace(face)
  face.removeFromDOM()

@facePrevAndDelete = (face) ->
  face.destroyed = "true" # Make sure face isn't saved on input blur.
  faceSetFocusEnd(face.prevFace)
  removeFace(face) if face.text == ""

@faceNextAndDelete = (face) ->
  face.destroyed = "true" # Make sure face isn't saved on input blur.
  faceSetFocusStart(face.nextFace)
  removeFace(face) if face.text == ""

@facePrev = (element) ->
  face = new Face(element)
  faceSetFocusEnd(face.prevFace)

@faceNext = (element) ->
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
    tray = new Tray
    wrapper = faceWrapper(this) # TODO: Remove "wrapper" and use face object instead.
    thisFace = new Face(this)
    $("#output").text e.which
    if e.which == 13
      if $(this).val() == "" && $(wrapper).next("[data-object=face-wrapper]").length == 0
        $(wrapper).data("destroyed", true) unless $(wrapper).prev("[data-object=face-wrapper]").length == 0
        tray.appendCube(this)
        cubeNext(this)
        removeFace(thisFace) unless $(wrapper).prev("[data-object=face-wrapper]").length == 0
      else
        thisFace.cube.appendFace(this)
        faceNext(this)
      e.preventDefault()
    else if e.which == 8 && $(wrapper).prev("[data-object=face-wrapper]").length > 0 && $(this).getCursorPosition() == 0 && nothingSelected(this) && $(this).val() == ""
      facePrevAndDelete(thisFace)
      e.preventDefault()
    else if e.which == 46 && $(wrapper).next("[data-object=face-wrapper]").length > 0 && $(this).getCursorPosition() == 0 && nothingSelected(this) && $(this).val() == ""
      faceNextAndDelete(thisFace)
      e.preventDefault()
    else if e.which == 38
      if $(wrapper).prev("[data-object=face-wrapper]").length > 0
        facePrev(this)
      else
        cubeParent(this)
      e.preventDefault()
    else if e.which == 40 && $(wrapper).next("[data-object=face-wrapper]").length > 0
      faceNext(this)
      e.preventDefault()
    else if e.which == 40 && $(this).closest("[data-object=cube-wrapper]").next("[data-object=cube-wrapper]").length > 0
      next_cube_wrapper = $(this).closest("[data-object=cube-wrapper]").next("[data-object=cube-wrapper]")
      setFocusEnd(next_cube_wrapper.find(".cube-input"))
    else if e.which == 66 && e.metaKey
      boldSelection(this)
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
