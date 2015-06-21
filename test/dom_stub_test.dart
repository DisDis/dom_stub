// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library dom_stub.test;

import 'package:test/test.dart';

//import 'package:dom_stub/dom_stub.dart';
import 'dart:js';
import     'dart:js' as testJs;

void main() {
  // See js_mimicry package
  group('A group of tests', () {
    context["A"] = "A";

    test('First Test', () {
      expect(context["A"], "A");
    });
  });
}

