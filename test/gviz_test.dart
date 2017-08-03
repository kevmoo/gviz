// Copyright (c) 2017, Kevin Moore. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:gviz/gviz.dart';
import 'package:test/test.dart';

void main() {
  test('empty', () {
    var graph = new Graph();
    expect(graph.toString(), 'digraph the_graph {\n}\n');
  });

  test('one node, one edge', () {
    var graph = new Graph()
      ..addNode('solo')
      ..addEdge('solo', 'solo');

    expect(graph.toString(), '''digraph the_graph {
  "solo";
  "solo" -> "solo";
}
''');
  });
}
