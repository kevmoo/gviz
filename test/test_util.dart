import 'package:gviz/gviz.dart';
import 'package:test/test.dart';

void gExpect(Gviz gviz, String expected) {
  final value = gviz.toString();
  printOnFailure(value);
  expect(value, expected);
}
