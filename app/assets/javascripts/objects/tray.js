"use strict";

function Tray() {}

Tray.prototype = {
  get _cube_wrappers() {
    return document.querySelectorAll("[data-object~=cube-wrapper]");
  },

  get cubes() {
    return Array.prototype.map.call(this._cube_wrappers, function(element) {
      return new Cube(element);
    });
  },

  appendCube: function(element, text) {
    if (text == null) text = "";
    // console.log("appendCube();");
    var cube = new Cube(element);
    var node = cube.appendCube(text);
    this.updateCubePositions(cube.position);
    return node;
  },

  updateCubePositions: function(start) {
    if (start == null) start = 0;
    // console.log("tray.updateCubePositions(" + start + ")");
    this.cubes.slice(start).forEach(function(cube, index) {
      cube.position = start + index + 1;
      cube.redrawPosition();
    });
  },
};

Tray.attachEventHandlers = function() {
  // document.body.addEventListener("click", Tray._cubeEventHandler);
  document.body.addEventListener("blur", Tray._cubeEventHandler, true);
  document.body.addEventListener("keydown", Tray._cubeEventHandler);
  document.body.addEventListener("keyup", Tray._cubeEventHandler);
  document.body.addEventListener("paste", Tray._cubeEventHandler);
};

Tray._cubeEventHandler = function(event) {
  if (event.target.classList.contains("cube-input")) {
    // console.log(event.type);
    switch (event.type) {
      case "blur":
        Tray._cubeBlurHandler(event);
        break;
      // case "click":
      //   Tray._cubeClickHandler(event);
      //   break;
      case "keydown":
        Tray._cubeKeydownHandler(event);
        break;
      case "keyup":
        Tray._cubeKeyupHandler(event);
        break;
      case "paste":
        Tray._cubePasteHandler(event);
        break;
    }
  }
};

Tray._cubeBlurHandler = function(event) {
  var cube = new Cube(event.target);
  cube.save("blur");
};

// Tray._cubeClickHandler = function(event) {
//   console.log("Tray._cubeClickHandler();")
// };

Tray._cubeKeydownHandler = function(event) {
  var that = event.target;
  var tray = new Tray();
  var thisCube = new Cube(that);
  var prevCube = thisCube.prevCube;
  var nextCube = thisCube.nextCube;
  document.getElementById("output").textContent = event.which; // TODO: Remove key output.
  if (event.which == 13 && thisCube.hasFaces()) {
    if (thisCube.faces.length === 0) thisCube.appendNewFaceToCubeWrapper();
    faceChildFirst(thisCube);
  } else if (event.which == 13) {
    tray.appendCube(that);
    cubeNext(that);
    event.preventDefault();
  } else if (event.which == 8 && prevCube && getCursorPosition(that) === 0 && nothingSelected(that) && thisCube.text === "") {
    cubePrevAndDelete(thisCube);
    event.preventDefault();
  } else if (event.which == 46 && nextCube && getCursorPosition(that) === 0 && nothingSelected(that) && thisCube.text === "") {
    cubeNextAndDelete(thisCube);
    event.preventDefault();
  } else if (event.which == 38 && prevCube && prevCube.hasFaces() && prevCube.faces.length > 0) {
    faceChildLast(prevCube);
  } else if (event.which == 38 && prevCube) {
    cubeSetFocusEnd(prevCube);
    event.preventDefault();
  } else if (event.which == 40 && thisCube.hasFaces() && thisCube.faces.length > 0) {
    faceChildFirst(thisCube);
    event.preventDefault();
  } else if (event.which == 40 && nextCube) {
    cubeSetFocusEnd(nextCube);
    event.preventDefault();
  } else if (event.which == 66 && event.metaKey) {
    boldSelection(that);
    event.preventDefault();
  }
};

Tray._cubeKeyupHandler = function(event) {
  var cube = new Cube(event.target);
  cube.redrawText() // Doesn't need a full redraw.
};


Tray._cubePasteHandler = function(event) {
  // var cube = new Cube(event.target);
  // cube.redrawText() // Doesn't need a full redraw.
  // TODO: Make cubePasteEvent a part of cube class. cube.pasteEvent(event);
  cubePasteEvent(event);
};
