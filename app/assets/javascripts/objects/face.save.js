"use strict";

Face.prototype._saveDone = function(request, event_type) {
  var data = JSON.parse(request.responseText);
  if (data != null) {
    this.positionOriginal = data.position;
    this.id = data.id;
    this.textOriginal = data.text;
    this.text = data.text;
    this.saving = "false";
    this.redraw();
    if (event_type == "blur") saveFacePositions(this.cube.wrapper);
  }
};

Face.prototype._saveFail = function(request) {
  this.saving = "false";
  console.error(request);
};

Face.prototype.save = function(event_type) {
  if (this.unchanged()) return;
  if (this.saving) return;
  if (this.destroyed) return;
  // console.log("face.save()");
  this.saving = "true";
  var params = {};
  params.face = {};
  params.face.position = this.position;
  params.face.text = this.text;

  var url = this.cube.url; // TODO: Refactor how URLs are generated.
  if (this.cube.id != null) {
    url += "/" + this.cube.id + "/faces";
  }
  if (this.id != null) {
    url += "/" + this.id;
    params._method = "patch";
  }

  var request = new XMLHttpRequest();
  request.open("POST", url, true);
  request.setRequestHeader("Accept", "application/json");
  request.setRequestHeader("Content-Type", "application/x-www-form-urlencoded; charset=UTF-8");
  request.setRequestHeader("X-CSRF-Token", csrfToken());
  // request.setRequestHeader("X-Requested-With", "XMLHttpRequest");

  var that = this;
  request.onreadystatechange = function() {
    if (this.readyState == 4 && this.status >= 200 && this.status < 300) {
      that._saveDone(request, event_type);
    } else if (this.readyState == 4) {
      that._saveFail(request);
    }
  };
  request.send(serializeForXMLHttpRequest(params));
};
