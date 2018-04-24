Cube.prototype._template_cube_input = function(text) {
  if (text == null) text = "";
  var cube_input = document.createElement("INPUT");
  cube_input.classList.add("cube-input");
  cube_input.setAttribute("placeholder", document.getElementById("language").getAttribute("data-enter-question-placeholder"));
  cube_input.setAttribute("type", "text");
  cube_input.setAttribute("value", text);
  return cube_input;
};

Cube.prototype._template_cube_type = function(type) {
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
};

Cube.prototype._template_cube_info = function() {
  var small_id = document.createElement("SMALL");
  var text_id = document.createTextNode(" #Ø");
  small_id.appendChild(text_id);
  var text_position = document.createTextNode("" + (this.position + 1));
  var cube_info = document.createElement("DIV");
  cube_info.classList.add("cube-id");
  cube_info.appendChild(small_id);
  cube_info.appendChild(text_position);
  return cube_info;
};

Cube.prototype._template_cube_div = function(text) {
  if (text == null) text = "";
  var cube_input = this._template_cube_input(text);
  var cube_type = this._template_cube_type();
  var cube_info = this._template_cube_info();

  var cube_div = document.createElement("DIV");
  cube_div.classList.add("cube");
  cube_div.appendChild(cube_input);
  cube_div.appendChild(cube_type);
  cube_div.appendChild(cube_info);
  return cube_div;
};

Cube.prototype._template_cube_faces = function() {
  var cube_faces = document.createElement("DIV");
  cube_faces.classList.add("cube-faces");
  return cube_faces;
};

Cube.prototype._template = function(text) {
  if (text == null) text = "";

  var cube_div = this._template_cube_div(text);
  var cube_faces = this._template_cube_faces();

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
};
