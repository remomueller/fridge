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
    this.cubes.slice(start).forEach(function(cube, index) {
      cube.position = start + index + 1;
      cube.redrawPosition();
    });
  }
};
