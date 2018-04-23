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

  _positionChanged: function() {
    return this.position !== this.positionOriginal;
  },

  _textChanged: function() {
    return this.text !== this.textOriginal;
  },

  _destroy: function() {
    this.wrapper = null;
    this.input = null;
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

  get text() {
    return this.input.value;
  },

  set text(val) {
    this.input.value = val;
  },

  get textOriginal() {
    return this.wrapper.getAttribute("data-text-original");
  },

  set textOriginal(val) {
    this.wrapper.setAttribute("data-text-original", val);
  },

  get url() {
    return this.wrapper.getAttribute("data-url");
  },

  get saving() {
    return this.wrapper.getAttribute("data-saving") == "true";
  },

  set saving(val) {
    this.wrapper.setAttribute("data-saving", val);
  },

  get destroyed() {
    return this.wrapper.getAttribute("data-destroyed") == "true";
  },

  set destroyed(val) {
    this.wrapper.setAttribute("data-destroyed", val);
  },

  // Returns next cube or null
  get nextFace() {
    var next = new Face(this.wrapper.nextElementSibling, this.cube);
    return (next.wrapper ? next : null);
  },

  // Returns prev cube or null
  get prevFace() {
    var prev = new Face(this.wrapper.previousElementSibling, this.cube);
    return (prev.wrapper ? prev : null);
  },

  // This function should draw all attributes to their visible locations and set
  // the appropriate class/es for the cube.
  redraw: function() {
    // console.log("face.redraw()");
    this.redrawText();
    this.redrawPosition();
  },

  // TODO: Implement
  redrawPosition: function() {
    // console.log("face.redrawPosition()");
    this.wrapper.querySelector(".face-id").innerHTML = this.position;
    if (this._positionChanged()) {
      this.wrapper.classList.add("face-wrapper-unsaved-position");
    } else {
      this.wrapper.classList.remove("face-wrapper-unsaved-position");
    }
  },

  // This does not modify input.value with "text original".
  redrawText: function() {
    // console.log("face.redrawText()");
    if (this._textChanged()) {
      this.wrapper.classList.add("face-wrapper-unsaved");
    } else {
      this.wrapper.classList.remove("face-wrapper-unsaved");
    }
  },

  // TODO: Implement
  _template: function(text) {
    return null;
  },

  appendFace: function(text) {
    if (text == null) text = "";
    var element = this._template(text);
    this.wrapper.insertAfter(element);
    return element; // TODO: Make this return a cube object.
  },

  save: function() {
    console.log("face.save();");
  },

  changed: function() {
    // console.log("CHANGED? ")
    // console.log("this._textChanged(): " + this._textChanged())
    // console.log("this._positionChanged(): " + this._positionChanged())
    return (this._positionChanged() || this._textChanged());
  },

  unchanged: function() {
    return !this.changed();
  },

  removeFromDOM: function() {
    console.log("removeFromDOM()");
    this.wrapper.remove();
    this._destroy();
  }
};
