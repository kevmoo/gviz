// Copyright (c) 2017, Kevin Moore. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:gviz/src/graph.dart';
import 'package:test/test.dart';

void main() {
  test('duplicate edge returns false', () {
    var graph = new Graph();

    expect(graph.addEdge(1, 2), isTrue);
    expect(graph.addEdge(1, 2), isFalse);
  });
}
