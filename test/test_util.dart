// Copyright (c) 2017, Kevin Moore. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:gviz/gviz.dart';
import 'package:test/test.dart';

void gExpect(Gviz gviz, String expected) {
  var value = gviz.toString();
  // Here to help debugging
  //print(value);

  expect(value, expected);
}
