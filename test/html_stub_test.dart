library dom_stub.htm.test;

import 'dart:html';

import 'package:test/test.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('Test dart:html namespace', () {
    test('Window location hash', () {
      when(window.location.hash).thenReturn('#');
      expect(window.location.hash, "#");
    });
  });
}