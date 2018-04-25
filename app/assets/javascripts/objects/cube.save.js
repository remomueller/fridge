"use strict";

Cube.prototype._save_done = function(request, event_type) {
  var data = JSON.parse(request.responseText);
  if (data != null) {
    this.positionOriginal = data.position;
    this.id = data.id;
    this.textOriginal = data.text;
    this.text = data.text;
    this.saving = "false";
    this.redraw();
    if (event_type == "blur") saveCubePositions(); // TODO: Refactor function.
    if (event_type == "paste") {
      this.faces.forEach(function(face) {
        face.save(event_type);
      });
      saveFacePositions(this.wrapper); // TODO: Refactor to: this.saveFacePositions(); and check if this is needed.
    }
  }
};

Cube.prototype._save_fail = function(request) {
  this.saving = "false";
  console.error(request);
};

Cube.prototype.save = function(event_type) {
  if (this.unchanged()) return;
  if (this.saving) return;
  if (this.destroyed) return;
  // console.log("cube.save()");
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
      that._save_done(request, event_type);
    } else if (this.readyState == 4) {
      that._save_fail(request);
    }
  };
  request.send(serializeForXMLHttpRequest(params));
};
