"use strict";

Cube.attachEventHandlers = function() {
  var tray = new Tray();
  if (!tray.wrapper) return;
  tray.wrapper.addEventListener("blur", Cube._eventHandler, true);
  // tray.wrapper.addEventListener("click", Cube._eventHandler);
  tray.wrapper.addEventListener("keydown", Cube._eventHandler);
  tray.wrapper.addEventListener("keyup", Cube._eventHandler);
  tray.wrapper.addEventListener("paste", Cube._eventHandler);
};

Cube._eventHandler = function(event) {
  if (event.target.classList.contains("cube-input")) {
    switch (event.type) {
      case "blur":
        Cube._eventBlur(event);
        break;
      // case "click":
      //   Cube._clickHandler(event);
      //   break;
      case "keydown":
        Cube._eventKeydown(event);
        break;
      case "keyup":
        Cube._eventKeyup(event);
        break;
      case "paste":
        Cube._eventPaste(event);
        break;
    }
  }
};

Cube._eventBlur = function(event) {
  var cube = new Cube(event.target);
  cube.save("blur");
};

// Cube._clickHandler = function(event) {
//   console.log("Cube._clickHandler(event);");
// };

Cube._eventKeydown = function(event) {
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

Cube._eventKeyup = function(event) {
  var cube = new Cube(event.target);
  cube.redrawText(); // Doesn't need a full redraw.
};


Cube._eventPaste = function(event) {
  // TODO: Make cubePasteEvent a part of cube class. cube.pasteEvent(event);
  cubePasteEvent(event);
};
