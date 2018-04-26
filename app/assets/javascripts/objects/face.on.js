"use strict";

Face.attachEventHandlers = function() {
  var tray = new Tray();
  if (!tray.wrapper) return;
  tray.wrapper.addEventListener("blur", Face._eventHandler, true);
  // tray.wrapper.addEventListener("click", Face._eventHandler);
  tray.wrapper.addEventListener("keydown", Face._eventHandler);
  tray.wrapper.addEventListener("keyup", Face._eventHandler);
  // tray.wrapper.addEventListener("paste", Face._eventHandler);
};

Face._eventHandler = function(event) {
  if (event.target.classList.contains("face-input")) {
    switch (event.type) {
      case "blur":
        Face._eventBlur(event);
        break;
      // case "click":
      //   Face._clickHandler(event);
      //   break;
      case "keydown":
        Face._eventKeydown(event);
        break;
      case "keyup":
        Face._eventKeyup(event);
        break;
      // case "paste":
      //   Face._eventPaste(event);
      //   break;
    }
  }
};

Face._eventBlur = function(event) {
  var face = new Face(event.target);
  face.save("blur");
};

// Face._clickHandler = function(event) {
//   console.log("Face._clickHandler(event);");
// };

Face._eventKeydown = function(event) {
  var that = event.target;
  var tray = new Tray();
  var thisFace = new Face(that);
  var prevFace = thisFace.prevFace;
  var nextFace = thisFace.nextFace;
  document.getElementById("output").textContent = event.which; // TODO: Remove key output.
  if (event.which == 13) {
    if (thisFace.text == "" && !nextFace) {
      if (prevFace) thisFace.destroyed = "true"; // TODO: Needs to actually be destroyed as well if it already exists.
      tray.appendCube(that);
      cubeNext(that);
      if (prevFace) thisFace.remove();
    } else {
      thisFace.cube.appendFace(that);
      faceNext(that);
    }
    event.preventDefault();
  } else if (event.which == 8 && prevFace && getCursorPosition(that) == 0 && nothingSelected(that) && thisFace.text == "") {
    thisFace.focusPreviousAndDelete();
    event.preventDefault();
  } else if (event.which == 46 && nextFace && getCursorPosition(that) == 0 && nothingSelected(that) && thisFace.text == "") {
    thisFace.focusNextAndDelete();
    event.preventDefault();
  } else if (event.which == 38) {
    if (prevFace) {
      faceSetFocusEnd(prevFace);
    } else {
      cubeSetFocusEnd(thisFace.cube);
    }
    event.preventDefault();
  } else if (event.which == 40 && nextFace) {
    faceSetFocusEnd(nextFace);
    event.preventDefault();
  } else if (event.which == 40 && thisFace.cube.nextCube) {
    cubeSetFocusEnd(thisFace.cube.nextCube);
  } else if (event.which == 66 && event.metaKey) {
    boldSelection(that);
    event.preventDefault();
  }
};

Face._eventKeyup = function(event) {
  var face = new Face(event.target);
  face.redrawText(); // Doesn't need a full redraw.
};

// Face._eventPaste = function(event) {
//   console.log("Face._eventPaste(event);");
// };
