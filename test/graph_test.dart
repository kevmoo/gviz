// Copyright (c) 2017, Kevin Moore. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:gviz/src/graph.dart';
import 'package:test/test.dart';

import 'test_util.dart';

void main() {
  test('duplicate edge returns false', () {
    var graph = new Graph();

    expect(graph.addEdge(1, 2), isTrue);
    expect(graph.addEdge(1, 2), isFalse);
  });

  group('createGviz', () {
    test('simple', () {
      var graph = new Graph()..addEdge(1, 2)..addEdge(1, 3)..addEdge(2, 3);

      var gviz = graph.createGviz();

      gExpect(gviz, r'''digraph the_graph {
  "1" [label="1"];
  "2" [label="2"];
  "1" -> "2";
  "3" [label="3"];
  "1" -> "3";
  "2" -> "3";
}
''');
    });

    test('name collisions', () {
      var graph = new Graph()
        ..addEdge(1, 2)
        ..addEdge(1, 3)
        ..addEdge(2, 3)
        ..addEdge('1', 1)
        ..addEdge('2', '1');

      var gviz = graph.createGviz();

      gExpect(gviz, r'''digraph the_graph {
  "1" [label="1"];
  "2" [label="2"];
  "1" -> "2";
  "3" [label="3"];
  "1" -> "3";
  "2" -> "3";
  "1_01" [label="1"];
  "1_01" -> "1";
  "2_01" [label="2"];
  "2_01" -> "1_01";
}
''');
    });
  });
}
