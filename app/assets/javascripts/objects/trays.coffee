################################################################################

@cubeWrapper = (element) ->
  wrapper = $(element).closest("[data-object~=cube-wrapper]")

################################################################################

@hasCubeFaces = (element) ->
  $(element).attr("data-cube-type") == "choice"

@saveCubePositions = ->
  tray = new Tray

  console.log "saveCubePositions()"
  url = ""
  params = {}
  params.cubes = {}

  $.each(tray.cubes, (index, cube) ->
    return true unless cube._positionChanged() # TODO: Change calling of "private" method?
    url = "#{cube.url}/positions" # TODO: Change to "tray.url"? currently is "/trays/1/cubes/positions.json"
    params.cubes["#{cube.id}"] = (
      "position": cube.position
    )
  )

  console.log params
  # console.log "url: #{url}"
  return unless !!url
  # console.log "server save positions"
  # console.log params
  $.post(
    url
    params
    null
    "json"
  ).done((data) ->
    if data?
      $.each(data, (index, servercube) ->
        element = document.querySelector("[data-object~=\"cube-wrapper\"][data-cube=\"#{servercube.id}\"]")
        cube = new Cube(element)
        if cube.wrapper
          cube.positionOriginal = servercube.position
          cube.redrawPosition()
        else
          console.log "Cube ##{servercube.id} not found."
      )
      # console.log "saveCubePositions: DONE"
  ).fail((data) ->
    console.log "saveCubePositions: FAIL"
    console.log "#{data}"
  )

@destroyCube = (cube) ->
  # console.log "destroyCube"
  cube.destroyed = "true"
  if !!cube.id
    params = {}
    params._method = "delete"
    url = "#{cube.url}/#{cube.id}"
    $.post(
      url
      params
      null
      "json"
    ).done((data) ->
      saveCubePositions() # Wait for completion
    )
  else
    saveCubePositions() # Always save cube positions


@updateCubePositions = (wrapper, position = parseInt($(wrapper).attr("data-position"))) ->
  $.each($(wrapper).nextAll("[data-object=cube-wrapper]"), (index, w) ->
    position += 1
    updateCubePosition(w, position)
  )

@updateCubePosition = (wrapper, position) ->
  $(wrapper).attr("data-position", position)
  redrawCubePosition(wrapper)

@redrawCubePosition = (wrapper) ->
  # console.log "redrawing NOAW "
  # console.log wrapper
  $(wrapper).find(".cube-id").html("<small>##{$(wrapper).data("cube") || "Ø"}</small> #{$(wrapper).attr("data-position")}")
  if $(wrapper).attr("data-position") != $(wrapper).attr("data-position-original")
    $(wrapper).addClass("cube-wrapper-unsaved-position")
  else
    $(wrapper).removeClass("cube-wrapper-unsaved-position")

@redrawCubeCubeType = (wrapper) ->
  $(wrapper).find(".cube-type").html("<small><a data-object=\"cube-details-clicker\" href=\"#\">#{$(wrapper).attr("data-cube-type")}</a></small>")

@removeCube = (cube) ->
  return unless cube.text == ""
  updateCubePositions(cube.wrapper, cube.position - 1)
  destroyCube(cube)
  cube.removeFromDOM()

@cubePrevAndDelete = (cube) ->
  cube.destroyed = "true" # Make sure cube isn't saved on input blur.
  cubeSetFocusEnd(cube.prevCube)
  removeCube(cube) if cube.text == ""

@cubeNextAndDelete = (cube) ->
  cube.destroyed = "true" # Make sure cube isn't saved on input blur.
  cubeSetFocusStart(cube.nextCube)
  removeCube(cube) if cube.text == ""

@cubeNext = (element) ->
  console.log "cubeNext"
  cube = new Cube(element)
  next = cube.nextCube
  cubeSetFocusEnd(next) if next

@cubeParent = (element) ->
  cube = new Cube(element)
  cubeSetFocusEnd(cube)

@cubeSetFocusEnd = (cube) ->
  setFocusEnd(cube.input) if cube && cube.input

@cubeSetFocusStart = (cube) ->
  setFocusStart(cube.input) if cube && cube.input

$(document)
  .on("keydown", "[data-object=cube-wrapper] .cube-input", (e) ->
    tray = new Tray
    thisCube = new Cube(this)
    prevCube = thisCube.prevCube
    nextCube = thisCube.nextCube

    wrapper = cubeWrapper(this)
    prev_wrapper = $(wrapper).prev("[data-object=cube-wrapper]")
    $("#output").text e.which
    if e.which == 13 && hasCubeFaces(wrapper)
      if $(wrapper).find("[data-object~=face-wrapper]").length == 0
        appendNewFaceToCubeWrapper(wrapper)
      faceChildFirst(wrapper)
    else if e.which == 13
      tray.appendCube(this)
      cubeNext(this)
      e.preventDefault()
    else if e.which == 8 && $(wrapper).prev("[data-object=cube-wrapper]").length > 0 && $(this).getCursorPosition() == 0 && nothingSelected($(this)) && $(this).val() == ""
      cubePrevAndDelete(thisCube)
      e.preventDefault()
    else if e.which == 46 && $(wrapper).next("[data-object=cube-wrapper]").length > 0 && $(this).getCursorPosition() == 0 && nothingSelected($(this)) && $(this).val() == ""
      cubeNextAndDelete(thisCube)
      e.preventDefault()
    else if e.which == 38 && prevCube.hasFaces() && prevCube.faces.length > 0
      faceChildLast(prev_wrapper)
    else if e.which == 38 && prevCube
      cubeSetFocusEnd(prevCube)
      e.preventDefault()
    else if e.which == 40 && thisCube.hasFaces() && thisCube.faces.length > 0
      faceChildFirst(wrapper)
      e.preventDefault()
    else if e.which == 40 && nextCube
      cubeSetFocusEnd(nextCube)
      e.preventDefault()
    else if e.which == 66 && e.metaKey
      boldSelection(this)
      e.preventDefault()
  )
  .on("keyup", "[data-object=cube-wrapper] .cube-input", (e) ->
    cube = new Cube(this)
    cube.redrawText() # Shouldn't need a full redraw.
  )
  .on("blur", "[data-object=cube-wrapper] .cube-input", (e) ->
    saveCubeNoCallbackPlusFaces(this, "blur")
  )
  .on("paste", "[data-object=cube-wrapper] .cube-input", (e) ->
    cubePasteEvent(e)
    # false
  )
