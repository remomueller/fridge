"use strict";

Tray.prototype.saveCubePositions = function() {
  console.log("tray.saveCubePositions();");
  var url = "";
  var params = {};
  params.cubes = {};

  this.cubes.forEach(function(cube, index) {
    if (!cube._positionChanged()) return true; // TODO: Change calling of "private" method?
    url = cube.url + "/positions"; // TODO: Change to tray.url? currently is "/trays/1/cubes/positions.json"
    params.cubes[cube.id] = { "position": cube.position };
  });

  console.log(params);
  if (!url) return;

  // TODO: Refactor "request" generation including passing in variables and functions.
  var request = new XMLHttpRequest();
  request.open("POST", url, true);
  request.setRequestHeader("Accept", "application/json");
  request.setRequestHeader("Content-Type", "application/x-www-form-urlencoded; charset=UTF-8");
  request.setRequestHeader("X-CSRF-Token", csrfToken());
  // request.setRequestHeader("X-Requested-With", "XMLHttpRequest");

  var that = this;
  request.onreadystatechange = function() {
    if (this.readyState == 4 && this.status >= 200 && this.status < 300) {
      that._saveCubePositionsDone(request);
    } else if (this.readyState == 4) {
      that._saveCubePositionsFail(request);
    }
  };
  request.send(serializeForXMLHttpRequest(params));
};

Tray.prototype._saveCubePositionsDone = function(request) {
  var data = JSON.parse(request.responseText);
  if (data != null) {
    data.forEach(function(datum) {
      var element = document.querySelector("[data-object~=\"cube-wrapper\"][data-cube=\"" + datum.id + "\"]");
      var cube = new Cube(element);
      if (cube.wrapper) {
        cube.positionOriginal = datum.position;
        cube.redrawPosition();
      } else {
        console.error("Cube #" + datum.id + " not found.");
      }
    });
  }
};

Tray.prototype._saveCubePositionsFail = function(request) {
  console.error(request);
};
