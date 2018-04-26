"use strict";

Tray.attachEventHandlers = function() {
  var wrapper = document.getElementById("cubes");
  if (!wrapper) return;
  // document.body.addEventListener("click", Tray._cubeEventHandler);
  wrapper.addEventListener("blur", Tray._cubeEventHandler, true);
  wrapper.addEventListener("keydown", Tray._cubeEventHandler);
  wrapper.addEventListener("keyup", Tray._cubeEventHandler);
  wrapper.addEventListener("paste", Tray._cubeEventHandler);
};

Tray._cubeEventHandler = function(event) {
  if (event.target.classList.contains("cube-input")) {
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
