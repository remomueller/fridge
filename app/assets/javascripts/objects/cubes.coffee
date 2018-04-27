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
  cube.nextCube.focusEnd() if cube.nextCube
