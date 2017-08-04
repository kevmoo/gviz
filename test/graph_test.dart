// Copyright (c) 2017, Kevin Moore. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:gviz/src/graph.dart';
import 'package:test/test.dart';

import 'test_util.dart';

void printGraph(Graph g) {
  for (var e in g.edges) {
    print('$e\t${e.flags}');
  }
}

void main() {
  test('duplicate edge returns false', () {
    var graph = new Graph();

    expect(graph.addEdge(1, 2), isTrue);
    expect(graph.addEdge(1, 2), isFalse);
  });

  group('flagEdges', () {
    test('simple', () {
      var graph = new Graph()..addEdge(1, 2);

      var flag = graph.flagEdge(1, 2);

      expect(flag, isNotNull);

      expect(graph.edges, hasLength(1));
      expect(graph.edges.single.flags.single, flag);
    });

    test('empty', () {
      var graph = new Graph();

      var flag = graph.flagEdge(1, 2);

      expect(flag, isNull);

      expect(graph.edges, isEmpty);
    });

    test('no match', () {
      var graph = new Graph()..addEdge(1, 2);

      var flag = graph.flagEdge(1, 3);

      expect(flag, isNull);

      expect(graph.edges, hasLength(1));
      expect(graph.edges.single.flags, isEmpty);
    });

    test('1-2-3', () {
      var graph = new Graph.fromEdges([
        [1, 2],
        [2, 3]
      ]);
      expect(graph.edges, hasLength(2));

      var flag = graph.flagEdge(1, 3);

      expect(flag, isNotNull);
      expect(graph.edgeFor(1, 2).flags.single, flag);
      expect(graph.edgeFor(2, 3).flags.single, flag);
    });

    test('1-2-3-1', () {
      var graph = new Graph.fromEdges([
        [1, 2],
        [2, 3],
        [3, 1]
      ]);
      expect(graph.edges, hasLength(3));

      var flag = graph.flagEdge(1, 3);

      expect(flag, isNotNull);
      expect(graph.edgeFor(1, 2).flags.single, flag);
      expect(graph.edgeFor(2, 3).flags.single, flag);
      expect(graph.edgeFor(3, 1).flags, isEmpty);
    });

    test('diamond', () {
      var graph = new Graph.fromEdges([
        [1, 2],
        [2, 4],
        [1, 3],
        [3, 4],
        [4, 5], // not interesting
        [0, 1], // not interesting
        [1, 5], // not interesting
      ]);
      expect(graph.edges, hasLength(7));

      var flag = graph.flagEdge(1, 4);

      expect(flag, isNotNull);

      expect(graph.edgeFor(1, 2).flags.single, flag);
      expect(graph.edgeFor(2, 4).flags.single, flag);
      expect(graph.edgeFor(1, 3).flags.single, flag);
      expect(graph.edgeFor(3, 4).flags.single, flag);
      expect(graph.edgeFor(4, 5).flags, isEmpty);
      expect(graph.edgeFor(0, 1).flags, isEmpty);
      expect(graph.edgeFor(1, 5).flags, isEmpty);
    });

    test('diamond one deeper', () {
      var graph = new Graph.fromEdges([
        [1, 2],
        [2, 4],
        [1, 3],
        [3, 4],
        [4, 5],
        [0, 1], // not interesting
        [1, 5],
      ]);
      expect(graph.edges, hasLength(7));

      var flag = graph.flagEdge(1, 5);

      expect(flag, isNotNull);

      expect(graph.edgeFor(1, 2).flags.single, flag);
      expect(graph.edgeFor(2, 4).flags.single, flag);
      expect(graph.edgeFor(1, 3).flags.single, flag);
      expect(graph.edgeFor(3, 4).flags.single, flag);
      expect(graph.edgeFor(4, 5).flags.single, flag);
      expect(graph.edgeFor(0, 1).flags, isEmpty);
      expect(graph.edgeFor(1, 5).flags.single, flag);
    });

    test('diamond one deeper, plus loop', () {
      var graph = new Graph.fromEdges([
        [1, 2],
        [2, 4],
        [1, 3],
        [3, 4],
        [4, 5],
        [0, 1], // not interesting
        [1, 5],
        [5, 1] // loop - not interesting
      ]);
      expect(graph.edges, hasLength(8));

      var flag = graph.flagEdge(1, 5);

      expect(flag, isNotNull);

      expect(graph.edgeFor(1, 2).flags.single, flag);
      expect(graph.edgeFor(2, 4).flags.single, flag);
      expect(graph.edgeFor(1, 3).flags.single, flag);
      expect(graph.edgeFor(3, 4).flags.single, flag);
      expect(graph.edgeFor(4, 5).flags.single, flag);
      expect(graph.edgeFor(0, 1).flags, isEmpty);
      expect(graph.edgeFor(1, 5).flags.single, flag);
      expect(graph.edgeFor(5, 1).flags, isEmpty);
    });
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
