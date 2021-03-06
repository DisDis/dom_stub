part of dom_stub.js_stub;

class JsProperty {
  final int id = JsObject._count++;
  final JsObject target;
  final JsFunction getter;
  final JsFunction setter;
  JsProperty(this.target, this.getter, this.setter);
  toString() => "JsProperty#$id";
}