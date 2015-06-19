library dom_stub.base;

import 'dart:collection';

const Object _UNDEFINED = const Object();
const bool _isDebug = false;

class JsFunction extends JsObject {
  final Function _function;
  JsFunction._internal(Function function)
      : _function = function,
        super.internal();

  JsFunction.internal(Function function)
      : _function = function,
        super.internal() {
    this["prototype"] = new JsObject.internal();
    this["apply"] = new JsFunction._internal((that, args) {
      return this.apply(args, thisArg: that);
    });
    this["call"] = new JsFunction._internal((that, [a1 = _UNDEFINED,
        a2 = _UNDEFINED, a3 = _UNDEFINED, a4 = _UNDEFINED, a5 = _UNDEFINED,
        a6 = _UNDEFINED, a7 = _UNDEFINED, a8 = _UNDEFINED, a9 = _UNDEFINED,
        a10 = _UNDEFINED]) {
      List args = [];
      if (a1 != _UNDEFINED) {
        args.add(a1);
      }
      if (a2 != _UNDEFINED) {
        args.add(a2);
      }
      if (a3 != _UNDEFINED) {
        args.add(a3);
      }
      if (a4 != _UNDEFINED) {
        args.add(a4);
      }
      if (a5 != _UNDEFINED) {
        args.add(a5);
      }
      if (a6 != _UNDEFINED) {
        args.add(a6);
      }
      if (a7 != _UNDEFINED) {
        args.add(a7);
      }
      if (a8 != _UNDEFINED) {
        args.add(a8);
      }
      if (a9 != _UNDEFINED) {
        args.add(a9);
      }
      if (a10 != _UNDEFINED) {
        args.add(a10);
      }
      return this.apply(args, thisArg: that);
    });
  }

  _getPrototypeValue(key) {
    var result;
    var prototype = (_obj["prototype"] as JsObject);
    if (prototype != null) {
      result = prototype._obj[key];
    }
    if (result == null) {
      if (_constructor != null) {
        return _constructor._getPrototypeValue(key);
      }
    }
    if (result == null) {
      return _UNDEFINED;
    } else {
      return result;
    }
  }

  /**
   * Returns a [JsFunction] that captures its 'this' binding and calls [f]
   * with the value of this passed as the first argument.
   */
  factory JsFunction.withThis(Function f) => new JsFunction.internal(f);

  /**
   * Invokes the JavaScript function with arguments [args]. If [thisArg] is
   * supplied it is the value of `this` for the invocation.
   */
  dynamic apply(List args, {thisArg}) {
    if (_isDebug){print("$this apply args:$args this:$thisArg");}
    if (thisArg == null) {
      thisArg = this;
    }
    if (args == null) {
      args = [];
    }
    return Function.apply(_function, [thisArg]..addAll(args));
  }
  @override
  toString() => "JsFunction#${id}";
}

class JsArray<E> extends JsObject with ListMixin<E> {
  List<E> _list;
  JsArray.internal([List list = const []])
      : _list = list,
        super.internal();

  factory JsArray.from(Iterable<E> other) =>
      new JsArray.internal(new List.from(other));

  _checkIndex(int index, {bool insert: false}) {
    int length = insert ? this.length + 1 : this.length;
    if (index is int && (index < 0 || index >= length)) {
      throw new RangeError.range(index, 0, length);
    }
  }

  _checkRange(int start, int end) {
    int cachedLength = this.length;
    if (start < 0 || start > cachedLength) {
      throw new RangeError.range(start, 0, cachedLength);
    }
    if (end < start || end > cachedLength) {
      throw new RangeError.range(end, start, cachedLength);
    }
  }

  // Methods required by ListMixin

  E operator [](index) {
    if (index is int) {
      _checkIndex(index);
    }
    return super[index];
  }

  void operator []=(index, E value) {
    if (index is int) {
      _checkIndex(index);
    }
    super[index] = value;
  }

  int get length => _list.length;

  void set length(int length) {
    _list.length = length;
  }

  // Methods overriden for better performance

  void add(E value) {
    //callMethod('push', [value]);
    _list.add(value);
  }

  void addAll(Iterable<E> iterable) {
    // TODO(jacobr): this can be optimized slightly.
    //callMethod('push', new List.from(iterable));
    _list.addAll(iterable);
  }

  void insert(int index, E element) {
    _checkIndex(index, insert: true);
    //callMethod('splice', [index, 0, element]);
    _list.insert(index, element);
  }

  E removeAt(int index) {
    _checkIndex(index);
    return _list.removeAt(index); //callMethod('splice', [index, 1])[0];
  }

  E removeLast() {
    if (length == 0) throw new RangeError(-1);
    return _list.removeLast(); //callMethod('pop');
  }

  void removeRange(int start, int end) {
    _checkRange(start, end);
    //callMethod('splice', [start, end - start]);
    _list.removeRange(start, end);
  }

  void setRange(int start, int end, Iterable<E> iterable, [int skipCount = 0]) {
    _checkRange(start, end);
    int length = end - start;
    if (length == 0) return;
    if (skipCount < 0) throw new ArgumentError(skipCount);
    //var args = [start, length]..addAll(iterable.skip(skipCount).take(length));
    //callMethod('splice', args);
    _list.setRange(start, end, iterable, skipCount);
  }

  void sort([int compare(E a, E b)]) {
    //callMethod('sort', [compare]);
    _list.sort(compare);
  }
  @override
  toString() => "JsArray#${id}";
}

class JsObject {
  Map<String, dynamic> _obj = {};
  JsFunction _constructor;
  static int _count = 0;
  final int id = _count++;
  @override
  toString() => "JsObject#${id}";
  JsObject.internal();

  /**
   * Constructs a new JavaScript object from [constructor] and returns a proxy
   * to it.
   */
  factory JsObject(JsFunction constructor, [List arguments]) =>
      _create(constructor, arguments);

  static JsObject _create(JsFunction constructor, arguments) {
    var result = new JsObject.internal().._constructor = constructor;
    result._obj["constructor"] = constructor;
    constructor.apply(arguments, thisArg: result);
    return result;
  }

  /**
   * Constructs a [JsObject] that proxies a native Dart object; _for expert use
   * only_.
   *
   * Use this constructor only if you wish to get access to JavaScript
   * properties attached to a browser host object, such as a Node or Blob, that
   * is normally automatically converted into a native Dart object.
   *
   * An exception will be thrown if [object] either is `null` or has the type
   * `bool`, `num`, or `String`.
   */
  factory JsObject.fromBrowserObject(object) {
    if (object is num || object is String || object is bool || object == null) {
      throw new ArgumentError("object cannot be a num, string, bool, or null");
    }
    return _fromBrowserObject(object);
  }

  /**
   * Recursively converts a JSON-like collection of Dart objects to a
   * collection of JavaScript objects and returns a [JsObject] proxy to it.
   *
   * [object] must be a [Map] or [Iterable], the contents of which are also
   * converted. Maps and Iterables are copied to a new JavaScript object.
   * Primitives and other transferrable values are directly converted to their
   * JavaScript type, and all other objects are proxied.
   */
  factory JsObject.jsify(object) {
    if ((object is! Map) && (object is! Iterable)) {
      throw new ArgumentError("object must be a Map or Iterable");
    }
    if (object is Map) {
      return new JsObject.internal().._obj = new Map.from(object);
    }

    return new JsArray.internal(new List.from(object));
  }

  operator [](property) {
    if (_isDebug){print("$this get['$property']");}
    var value = null;
    if (!_obj.containsKey(property)) {
      if (_constructor != null) {
        value = _constructor._getPrototypeValue(property);
      }
    } else {
      value = _obj[property];
    }
    if (value is JsProperty) {
      var propertyO = (value as JsProperty);
      if (propertyO.getter != null) {
        return propertyO.getter.apply(null, thisArg: this);
      }
      return null;
    }
    return value == _UNDEFINED ? null : value;
  }

  operator []=(property, value) {
    if (_isDebug){print("$this set['$property'] = '$value'");}
    var current = null;
    if (!_obj.containsKey(property)) {
      if (_constructor != null) {
        current = _constructor._getPrototypeValue(property);
      }
    } else {
      current = _obj[property];
    }
    if (current is JsProperty) {
      var property = (current as JsProperty);
      if (property.setter != null) {
        property.setter.apply([value], thisArg: this);
      }
    } else {
      _obj[property] = value;
    }
  }

  callMethod(String method, [List args]) {
    if (_isDebug){print("$this call-> '$method' args:$args");}
    return (this[method] as JsFunction).apply(args, thisArg: this);
  }

  void deleteProperty(String property) => _obj.remove(property);

  bool hasProperty(String property) => _obj.containsKey(property);

  bool instanceof(JsFunction type) => _constructor == type ||
      (_constructor != null && _constructor.instanceof(type));
}

class JsProperty {
  final int id = JsObject._count++;
  final JsObject target;
  final JsFunction getter;
  final JsFunction setter;
  JsProperty(this.target, this.getter, this.setter);
  toString() => "JsProperty#$id";
}

JsObject _context = _contextCreate();
JsObject get context => _context;

JsObject _contextCreate() {
  var result = new JsObject.internal();
  result["Object"] = new JsFunction.withThis((_) {});
  result["Object"]["defineProperty"] = new JsFunction.withThis((that, obj, prop,
      descriptor) {
    var getter = descriptor['get'];
    var setter = descriptor['set'];
    obj._obj[prop] = new JsProperty(obj, getter, setter);
  });
  return result;
}
