Face.prototype._template_face_prepend = function(text) {
  var text_dash = document.createTextNode("-");
  var face_prepend = document.createElement("DIV");
  face_prepend.classList.add("face-prepend");
  face_prepend.appendChild(text_dash);
  return face_prepend;
};

Face.prototype._template_face_input = function(text) {
  if (text == null) text = "";
  var face_input = document.createElement("INPUT");
  face_input.classList.add("face-input");
  face_input.setAttribute("placeholder", document.getElementById("language").getAttribute("data-enter-option-placeholder"));
  face_input.setAttribute("type", "text");
  face_input.setAttribute("value", text);
  return face_input;
};

Face.prototype._template_face_info = function(text) {
  var text_position = document.createTextNode("" + (this.position + 1));
  var face_info = document.createElement("DIV");
  face_info.classList.add("face-id");
  face_info.appendChild(text_position);
  return face_info;
};

Face.prototype._template = function(text) {
  if (text == null) text = "";
  var face_prepend = this._template_face_prepend();
  var face_input = this._template_face_input(text);
  var face_info = this._template_face_info();
  var element = document.createElement("DIV");
  element.classList.add("face-wrapper"); // IE11 compatibility, add class one at a time: https://caniuse.com/#search=classList
  element.classList.add("face-wrapper-unsaved");
  element.setAttribute("data-tray", this.wrapper.getAttribute("data-tray")); // TODO: Remove?
  element.setAttribute("data-cube", this.wrapper.getAttribute("data-cube")); // TODO: Remove?
  element.setAttribute("data-object", "face-wrapper");
  element.setAttribute("data-url", this.wrapper.getAttribute("data-url"));
  element.setAttribute("data-position", this.position + 1);
  element.appendChild(face_prepend);
  element.appendChild(face_input);
  element.appendChild(face_info);
  return element;
};
