// Copyright (c) 2017, Kevin Moore. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:gviz/gviz.dart';
import 'package:test/test.dart';

void gExpect(Gviz gviz, String expected) {
  final value = gviz.toString();
  printOnFailure(value);
  expect(value, expected);
}
