@cubesReady = ->
  $("#cubes").sortable(
    axis: "y"
    forcePlaceholderSize: true
    handle: ".cube-id"
    placeholder: "cube-wrapper-placeholder"
    stop: (event, ui) ->
      tray = new Tray
      tray.updateCubePositions()
  )

@cubeNext = (element) -> # TODO: Remove this function.
  cube = new Cube(element)
  cubeSetFocusEnd(cube.nextCube)

@cubeSetFocusEnd = (cube) ->
  setFocusEnd(cube.input) if cube && cube.input

@cubeSetFocusStart = (cube) ->
  setFocusStart(cube.input) if cube && cube.input
