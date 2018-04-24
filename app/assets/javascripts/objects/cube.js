"use strict";

function Cube(element) {
  this.wrapper = this._getWrapper(element);
  this.input = this.wrapper ? this.wrapper.querySelector(".cube-input") : null;
}

Cube.prototype = {
  // Private getters and functions.
  get _face_wrappers() {
    return this.wrapper.querySelectorAll("[data-object~=face-wrapper]");
  },

  _getWrapper: function(element) {
    if (element) {
      return element.closest("[data-object~=cube-wrapper]");
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

  // Public getters, setters, and functions.
  get faces() {
    var that = this;
    return Array.prototype.map.call(this._face_wrappers, function(element) {
      return new Face(element, that);
    });
  },

  get id() {
    return this.wrapper.getAttribute("data-cube") || null;
  },

  set id(val) {
    this.wrapper.setAttribute("data-cube", val);
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

  get cubeType() {
    return this.wrapper.getAttribute("data-cube-type");
  },

  set cubeType(val) {
    this.wrapper.setAttribute("data-cube-type", val);
  },

  get url() {
    return this.wrapper.getAttribute("data-url");
  },

  get saving() {
    return this.wrapper.getAttribute("data-saving") === "true";
  },

  set saving(val) {
    this.wrapper.setAttribute("data-saving", val);
  },

  get destroyed() {
    return this.wrapper.getAttribute("data-destroyed") === "true";
  },

  set destroyed(val) {
    this.wrapper.setAttribute("data-destroyed", val);
  },

  // Returns next cube or null
  get nextCube() {
    var next = new Cube(this.wrapper.nextElementSibling);
    return (next.wrapper ? next : null);
  },

  // Returns prev cube or null
  get prevCube() {
    var prev = new Cube(this.wrapper.previousElementSibling);
    return (prev.wrapper ? prev : null);
  },

  // This function should draw all attributes to their visible locations and set
  // the appropriate class/es for the cube.
  redraw: function() {
    this.redrawText();
    this.redrawPosition();
    // this.redrawCubeType(); // TODO: Check if this should be redrawn as well.
  },

  redrawPosition: function() {
    // console.log("redrawPosition()");
    this.wrapper.querySelector(".cube-id").innerHTML = "<small>#" + (this.id || "Ø") + "</small> " + this.position;
    if (this._positionChanged()) {
      this.wrapper.classList.add("cube-wrapper-unsaved-position");
    } else {
      this.wrapper.classList.remove("cube-wrapper-unsaved-position");
    }
  },

  // This does not modify input.value with "text original".
  redrawText: function() {
    // console.log("redrawText()");
    if (this._textChanged()) {
      this.wrapper.classList.add("cube-wrapper-unsaved");
    } else {
      this.wrapper.classList.remove("cube-wrapper-unsaved");
    }
  },

  redrawCubeType: function() {
    // console.log("redrawCubeType()");
    var cube_type = this.wrapper.querySelector(".cube-type");
    cube_type.replaceWith(this._template_cube_type(this.cubeType));
  },

  _template_cube_type: function(type) {
    if (type == null) type = "string";
    var small_link = document.createElement("SMALL");
    var cube_type_link = document.createElement("A");
    var cube_type_link_text = document.createTextNode(type);
    cube_type_link.setAttribute("data-object", "cube-details-clicker");
    cube_type_link.setAttribute("href", "#");
    cube_type_link.appendChild(cube_type_link_text);
    small_link.appendChild(cube_type_link);

    var cube_type = document.createElement("DIV");
    cube_type.classList.add("cube-type");
    cube_type.appendChild(small_link);

    return cube_type;
  },

  _template: function(text) {
    if (text == null) text = "";
    var cube_input = document.createElement("INPUT");
    cube_input.classList.add("cube-input");
    cube_input.setAttribute("placeholder", document.getElementById("language").getAttribute("data-enter-question-placeholder"));
    cube_input.setAttribute("type", "text");
    cube_input.setAttribute("value", text);

    var cube_type = this._template_cube_type();

    var small_id = document.createElement("SMALL");
    var text_id = document.createTextNode(" #Ø");
    small_id.appendChild(text_id);
    var text_position = document.createTextNode("" + (this.position + 1));

    var cube_info = document.createElement("DIV");
    cube_info.classList.add("cube-id");
    cube_info.appendChild(small_id);
    cube_info.appendChild(text_position);

    var cube_div = document.createElement("DIV");
    cube_div.classList.add("cube");
    cube_div.appendChild(cube_input);
    cube_div.appendChild(cube_type);
    cube_div.appendChild(cube_info);

    var cube_faces = document.createElement("DIV");
    cube_faces.classList.add("cube-faces");

    var element = document.createElement("DIV");
    element.classList.add("cube-wrapper"); // IE11 compatibility, add class one at a time: https://caniuse.com/#search=classList
    element.classList.add("cube-wrapper-unsaved");
    element.setAttribute("data-object", "cube-wrapper");
    element.setAttribute("data-tray", this.wrapper.getAttribute("data-tray")); // TODO: Remove?
    element.setAttribute("data-url", this.wrapper.getAttribute("data-url"));
    element.setAttribute("data-position", this.position + 1);
    element.appendChild(cube_div);
    element.appendChild(cube_faces);
    return element;
  },

  appendCube: function(text) {
    if (text == null) text = "";
    var element = this._template(text);
    this.wrapper.insertAfter(element);
    return element; // TODO: Make this return a cube object.
  },

  changed: function() {
    return (this._positionChanged() || this._textChanged());
  },

  unchanged: function() {
    return !this.changed();
  },

  // Returns true if cubeType is "choice".
  hasFaces: function() {
    return (this.cubeType == "choice");
  },

  removeFromDOM: function() {
    // console.log("removeFromDOM()");
    this.wrapper.remove();
    this._destroy();
  }
};
