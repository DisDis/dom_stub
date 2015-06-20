# dom_stub

A library for Dart developers.
Implementing 'dart:js'. It allows to run browser test in VM mode.

## Usage


Try It Now
-----------
Add the js_mimicry package to your pubspec.yaml file:

```yaml
dependencies:
  dom_stub: ">=0.0.1 <0.1.0"
```

Building and Deploying
----------------------

To build a deployable version of your test, add the dom_stub transformers to your
pubspec.yaml file:

```yaml
transformers:
- dom_stub
```

A simple usage example:

```bash
DOM_STUB="true" pub serve
pub run test --pub-serve=8080 -p vm
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/DisDis/dom_stub/issues
