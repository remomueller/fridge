$(document)
  .on("click", "[data-object~=cube-details-clicker]", ->
    cube_wrapper = cubeWrapper(this)
    $("#cube-details-edit-box").removeClass("d-none")
    $("#cube-details-edit-box").data("cube", cube_wrapper.data("cube"))
    $("#cube-details-id").html(cube_wrapper.data("cube"))
    $("#cube_cube_type").val(cube_wrapper.attr("data-cube-type"))
    console.log $("#cube-details-edit-box").data("cube")
    # cubeWrapper(this).find(".cube-input").toggleClass("active")
    false
  )
  .on("change", "#cube_cube_type", ->
    $element = $("#cube-details-edit-box")
    console.log "YOYYO"
    return unless !!$element.data("cube")
    console.log "cube_type change"

    params = {}
    params.cube = {}
    params.cube.cube_type = $(this).val()
    url = "#{$element.data("url")}/#{$element.data("cube")}"
    console.log "$element.data(\"url\"): #{$element.data("url")}"
    console.log "$element.data(\"cube\"): #{$element.data("cube")}"
    params._method = "patch"
    console.log params
    $.post(
      url
      params
      null
      "json"
    ).done((data) ->
      if data?
        console.log "DATA:"
        cube_wrapper = $("[data-object~=cube-wrapper][data-cube=#{data.id}]").first()
        cube_wrapper.attr("data-cube-type", data.cube_type)
        redrawCubeCubeType(cube_wrapper)
        if hasCubeFaces(cube_wrapper) && faceWrappers(cube_wrapper).length == 0
          appendNewFaceToCubeWrapper(cube_wrapper)
    ).fail((data) ->
      console.log "fail: #{data}"
    )
  )
  .on("click", "[data-object~=cube-details-clicker-close]", ->
    $("#cube-details-edit-box").addClass("d-none")
    $("#cube-details-edit-box").data("cube", null)
    $("#cube_cube_type").val("")
    false
  )
