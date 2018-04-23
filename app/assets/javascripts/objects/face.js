"use strict";

function Face(element, cube) {
  this.wrapper = this._getWrapper(element);
  this.input = this.wrapper ? this.wrapper.querySelector(".face-input") : null;
  this.cube = cube;
}

Face.prototype = {
  // Private
  _getWrapper: function(element) {
    if (element) {
      return element.closest("[data-object~=face-wrapper]");
    } else {
      return null;
    }
  },

  // Public
  get id() {
    return this.wrapper.getAttribute("data-face");
  },

  set id(val) {
    this.wrapper.setAttribute("data-face", val);
  },

  get position() {
    return parseInt(this.wrapper.getAttribute("data-position"));
  },

  set position(val) {
    this.wrapper.setAttribute("data-position", val);
  },

  get positionOriginal() {
    return parseInt(this.wrapper.getAttribute("data-position-original"));
  },

  set positionOriginal(val) {
    this.wrapper.setAttribute("data-position-original", val);
  },

  // TODO: Implement these.
  // get text() {
  //   return this.input.value;
  // },

  // set text(val) {
  //   this.input.value = val;
  // },

  // get textOriginal() {
  //   return this.wrapper.getAttribute("data-text-original");
  // },

  // set textOriginal(val) {
  //   this.wrapper.setAttribute("data-text-original", val);
  // },

};
