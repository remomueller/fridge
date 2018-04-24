Cube.prototype.save = function(event_type) {
  if (this.unchanged()) return;
  if (this.saving) return;
  if (this.destroyed) return;
  console.log("cube.save()");
  this.saving = "true";
  var params = {};
  params.cube = {};
  params.cube.position = this.position;
  params.cube.text = this.text;
  params.cube.cube_type = this.cubeType;
  var url = this.url;
  if (this.id != null) {
    url += "/" + this.id;
    params._method = "patch";
  }
  // console.log(params);

  var request = new XMLHttpRequest();
  request.open("POST", url, true);
  request.setRequestHeader("Accept", "application/json");
  request.setRequestHeader("Content-Type", "application/x-www-form-urlencoded; charset=UTF-8");
  request.setRequestHeader("X-CSRF-Token", csrfToken());
  // request.setRequestHeader("X-Requested-With", "XMLHttpRequest");

  var that = this;
  request.onreadystatechange = function() {
    if (this.readyState == 4 && this.status >= 200 && this.status < 300) {
      var data = JSON.parse(request.responseText);
      if (data != null) {
        that.positionOriginal = data.position;
        that.id = data.id;
        that.textOriginal = data.text;
        that.text = data.text;
        that.saving = "false";
        that.redraw();
        if (event_type == "blur") saveCubePositions();
        if (event_type == "paste") {
          that.faces.forEach(function(face) {
            saveFace(face.input, event_type);
          });
          saveFacePositions(that.wrapper); // TODO: Refactor to: that.saveFacePositions(); and check if this is needed.
        }
      }
    } else if (this.readyState == 4) {
      that.saving = "false";
      console.error(request);
    }
  };
  request.send(serializeForXMLHttpRequest(params));
};
