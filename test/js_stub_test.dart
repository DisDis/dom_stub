library dom_stub.test;

import 'package:test/test.dart';

import 'dart:js';

void main() {
  // See js_mimicry package
  group('A group of tests', () {
    context["A"] = "A";

    test('First Test', () {
      expect(context["A"], "A");
    });
  });
}

