# @Face = (element) ->
#   if $(element).hasClass("face-wrapper")
#     @wrapper = $(element).first()
#   else
#     @wrapper = $(element).closest("[data-object~=face-wrapper]")
#   return

# @Face::cube = ->
#   new Cube(@wrapper)


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

@faceTextUnchanged = (wrapper, element) ->
  $(wrapper).attr("data-text") == $(element).val()

@faceTextChanged = (wrapper, element) ->
  $(wrapper).attr("data-text") != $(element).val()

@saveFace = (element) ->
  wrapper = faceWrapper(element)
  return if faceTextUnchanged(wrapper, element)
  return if $(wrapper).data("destroyed")
  params = {}
  params.face = {}
  params.face.position = $(wrapper).attr("data-position")
  params.face.text = $(element).val()


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


  # url = $(wrapper).data("url")
  # if $(wrapper).data("face")?
  #   url += "/#{$(wrapper).data("face")}"
  #   params._method = "patch"

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
      saveFacePositions(cubeWrapper(wrapper))
  ).fail((data) ->
    console.log "fail: #{data}"
  )

@saveFacePositions = (cube_wrapper) ->
  # console.log "saveFacePositions()"
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

@destroyFace = (element) ->
  # console.log "destroyFace"
  wrapper = faceWrapper(element)
  if !!$(wrapper).data("face")
    params = {}
    params._method = "delete"
    url = "#{$(wrapper).data("url")}/#{$(wrapper).data("face")}"
    $.post(
      url
      params
      null
      "json"
    ).done((data) ->
      saveFacePositions(cubeWrapper(wrapper)) # Wait for completion
    )
  else
    saveFacePositions(cubeWrapper(wrapper)) # Always save face positions

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

@redrawFaceWrapper = (wrapper, element) ->
  $(wrapper).removeClass("face-wrapper-unsaved")
  if faceTextChanged(wrapper, element)
    $(wrapper).addClass("face-wrapper-unsaved")
  else
    $(wrapper).removeClass("face-wrapper-unsaved")

@removeFace = (element) ->
  wrapper = faceWrapper(element)
  return unless $(element).val() == ""
  updateFacePositions(wrapper, parseInt($(wrapper).attr("data-position")) - 1)
  destroyFace(element)
  $(wrapper).remove()

@facePrevAndDelete = (element) ->
  wrapper = faceWrapper(element)
  $(wrapper).data("destroyed", true) # Make sure face isn't saved on input blur.
  setFocusEnd($(wrapper).prev("[data-object=face-wrapper]").find(".face-input"))
  removeFace($(element)) if $(element).val() == ""

@faceNextAndDelete = (element) ->
  wrapper = faceWrapper(element)
  $(wrapper).data("destroyed", true) # Make sure face isn't saved on input blur.
  setFocusStart($(wrapper).next("[data-object=face-wrapper]").find(".face-input"))
  removeFace($(element)) if $(element).val() == ""

@facePrev = (element) ->
  wrapper = faceWrapper(element)
  setFocusEnd($(wrapper).prev("[data-object=face-wrapper]").find(".face-input"))

@faceNext = (element) ->
  wrapper = faceWrapper(element)
  setFocusEnd($(wrapper).next("[data-object=face-wrapper]").find(".face-input"))

@faceChildFirst = (cube_wrapper) ->
  setFocusEnd($(cube_wrapper).find("[data-object~=face-wrapper]").first().find(".face-input"))

@faceChildLast = (cube_wrapper) ->
  setFocusEnd($(cube_wrapper).find("[data-object~=face-wrapper]").last().find(".face-input"))

# Check if changes are made to element text.
@faceChangesMade = (element) ->
  wrapper = faceWrapper(element)
  redrawFaceWrapper(wrapper, element)

$(document)
  .on("keydown", "[data-object=face-wrapper] .face-input", (e) ->
    tray = new Tray
    wrapper = faceWrapper(this)
    $("#output").text e.which
    if e.which == 13
      if $(this).val() == "" && $(wrapper).next("[data-object=face-wrapper]").length == 0
        $(wrapper).data("destroyed", true) unless $(wrapper).prev("[data-object=face-wrapper]").length == 0
        tray.appendCube(this)
        cubeNext(this)
        removeFace(this) unless $(wrapper).prev("[data-object=face-wrapper]").length == 0
      else
        appendNewFace(this)
        faceNext(this)
      e.preventDefault()
    else if e.which == 8 && $(wrapper).prev("[data-object=face-wrapper]").length > 0 && $(this).getCursorPosition() == 0 && nothingSelected($(this)) && $(this).val() == ""
      facePrevAndDelete($(this))
      e.preventDefault()
    else if e.which == 46 && $(wrapper).next("[data-object=face-wrapper]").length > 0 && $(this).getCursorPosition() == 0 && nothingSelected($(this)) && $(this).val() == ""
      faceNextAndDelete($(this))
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
    faceChangesMade(this)
  )
  .on("blur", "[data-object=face-wrapper] .face-input", (e) ->
    saveFace(this)
  )
