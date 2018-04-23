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

@faceTemplateHelper = (tray, cube, url, position = 1, text = "") ->
  console.log "Face CUBE: #{cube}"
  console.log "Face URL: #{url}"
  face_prepend = $("<div>"
    class: "face-prepend"
  ).append("-")
  face_input = $("<input>"
    class: "face-input"
    placeholder: $("#language").data("enter-option-placeholder")
    type: "text"
    value: text
  )
  face_id = $("<div>"
    class: "face-id"
  ).append("#{position}")
  $("<div>"
    class: "face-wrapper face-wrapper-unsaved"
    "data-object": "face-wrapper"
    "data-cube": cube
    "data-url": url
    "data-position": position
  ).append(face_prepend).append(face_input).append(face_id)

@faceTemplate = (element, text) ->
  wrapper = faceWrapper(element)
  position = parseInt($(wrapper).attr("data-position")) + 1
  tray = $(wrapper).data("tray")
  cube = $(wrapper).data("cube")
  url = $(wrapper).data("url")
  faceTemplateHelper(tray, cube, url, position, text)

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
  face.destroyed == "true"
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

@appendNewFace = (element, text = "") ->
  # console.log "appendNewFace"
  wrapper = faceWrapper(element)
  newElement = faceTemplate(element, text)
  $(wrapper).after(newElement)
  updateFacePositions(wrapper)
  $(wrapper).next("[data-object=face-wrapper]")

@appendNewFaceToCubeWrapper = (wrapper, position = 1, text = "") ->
  newElement = faceTemplateHelper($(wrapper).data("tray"), $(wrapper).data("cube"), "#{$(wrapper).data("url")}/#{$(wrapper).data("cube")}/faces", position, text) ## similar to appendNewFAce
  $(wrapper).find(".cube-faces").append(newElement)


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
  cube = new Cube(element)
  face = new Face(element, cube)
  faceSetFocusEnd(face.prevFace)

@faceNext = (element) ->
  cube = new Cube(element)
  face = new Face(element, cube)
  faceSetFocusEnd(face.nextFace)

@faceChildFirst = (cube_wrapper) ->
  setFocusEnd($(cube_wrapper).find("[data-object~=face-wrapper]").first().find(".face-input"))

@faceChildLast = (cube_wrapper) ->
  setFocusEnd($(cube_wrapper).find("[data-object~=face-wrapper]").last().find(".face-input"))

@faceSetFocusEnd = (face) -> # Could be refactored to work for cubes and faces
  setFocusEnd(face.input) if face && face.input

@faceSetFocusStart = (face) -> # Could be refactored to work for cubes and faces
  setFocusStart(face.input) if face && face.input

$(document)
  .on("keydown", "[data-object=face-wrapper] .face-input", (e) ->
    tray = new Tray
    wrapper = faceWrapper(this)

    thisCube = new Cube(this) # TODO: Cleanup
    thisFace = new Face(this, thisCube) # TODO, make cube optional?

    $("#output").text e.which
    if e.which == 13
      if $(this).val() == "" && $(wrapper).next("[data-object=face-wrapper]").length == 0
        $(wrapper).data("destroyed", true) unless $(wrapper).prev("[data-object=face-wrapper]").length == 0
        tray.appendCube(this)
        cubeNext(this)
        removeFace(thisFace) unless $(wrapper).prev("[data-object=face-wrapper]").length == 0
      else
        appendNewFace(this)
        faceNext(this)
      e.preventDefault()
    else if e.which == 8 && $(wrapper).prev("[data-object=face-wrapper]").length > 0 && $(this).getCursorPosition() == 0 && nothingSelected($(this)) && $(this).val() == ""

      facePrevAndDelete(thisFace)
      e.preventDefault()
    else if e.which == 46 && $(wrapper).next("[data-object=face-wrapper]").length > 0 && $(this).getCursorPosition() == 0 && nothingSelected($(this)) && $(this).val() == ""
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
    cube = new Cube(this)
    face = new Face(this, cube)
    face.redrawText()
  )
  .on("blur", "[data-object=face-wrapper] .face-input", (e) ->
    saveFace(this, "blur")
  )
