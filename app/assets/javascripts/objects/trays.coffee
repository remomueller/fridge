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
  console.log "destroyCube(cube);"
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
    )

@removeCube = (cube) ->
  return unless cube.text == ""
  position = cube.position - 1 # Needs to be stored before cube is destroyed/removed.
  destroyCube(cube)
  cube.removeFromDOM()
  tray = new Tray
  tray.updateCubePositions(position - 1) # Needs to be done after cube is removed from DOM
  saveCubePositions()

@cubePrevAndDelete = (cube) ->
  cube.destroyed = "true" # Make sure cube isn't saved on input blur.
  cubeSetFocusEnd(cube.prevCube)
  removeCube(cube) if cube.text == ""

@cubeNextAndDelete = (cube) ->
  cube.destroyed = "true" # Make sure cube isn't saved on input blur.
  cubeSetFocusStart(cube.nextCube)
  removeCube(cube) if cube.text == ""

@cubeNext = (element) ->
  cube = new Cube(element)
  cubeSetFocusEnd(cube.nextCube)

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
    $("#output").text e.which
    if e.which == 13 && thisCube.hasFaces()
      if thisCube.faces.length == 0
        thisCube.appendNewFaceToCubeWrapper()
      faceChildFirst(thisCube)
    else if e.which == 13
      tray.appendCube(this)
      cubeNext(this)
      e.preventDefault()
    else if e.which == 8 && prevCube && $(this).getCursorPosition() == 0 && nothingSelected($(this)) && $(this).val() == ""
      cubePrevAndDelete(thisCube)
      e.preventDefault()
    else if e.which == 46 && nextCube && $(this).getCursorPosition() == 0 && nothingSelected($(this)) && $(this).val() == ""
      cubeNextAndDelete(thisCube)
      e.preventDefault()
    else if e.which == 38 && prevCube && prevCube.hasFaces() && prevCube.faces.length > 0
      faceChildLast(prevCube)
    else if e.which == 38 && prevCube
      cubeSetFocusEnd(prevCube)
      e.preventDefault()
    else if e.which == 40 && thisCube.hasFaces() && thisCube.faces.length > 0
      faceChildFirst(thisCube)
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
    cube = new Cube(this)
    cube.save("blur")
  )
  .on("paste", "[data-object=cube-wrapper] .cube-input", (e) ->
    cubePasteEvent(e)
    # false
  )
