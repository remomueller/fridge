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
  tray.updateCubePositions(position) # Needs to be done after cube is removed from DOM
  tray.saveCubePositions()

@cubePrevAndDelete = (cube) ->
  cube.destroyed = "true" # Make sure cube isn't saved on input blur.
  cubeSetFocusEnd(cube.prevCube)
  removeCube(cube) if cube.text == ""

@cubeNextAndDelete = (cube) ->
  cube.destroyed = "true" # Make sure cube isn't saved on input blur.
  cubeSetFocusStart(cube.nextCube)
  removeCube(cube) if cube.text == ""

@cubeNext = (element) -> # TODO: Remove this function.
  cube = new Cube(element)
  cubeSetFocusEnd(cube.nextCube)

@cubeParent = (element) ->
  cube = new Cube(element)
  cubeSetFocusEnd(cube)

@cubeSetFocusEnd = (cube) ->
  setFocusEnd(cube.input) if cube && cube.input

@cubeSetFocusStart = (cube) ->
  setFocusStart(cube.input) if cube && cube.input

@traysReady = ->
  Tray.attachEventHandlers()
