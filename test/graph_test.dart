// Copyright (c) 2017, Kevin Moore. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:gviz/gviz.dart';
import 'package:test/test.dart';

import 'test_util.dart';

void printGraph(Graph g) {
  for (var e in g.edges) {
    print('$e\t${e.flags}');
  }
}

void main() {
  test('duplicate edge returns false', () {
    final graph = Graph();

    expect(graph.addEdge(1, 2), isTrue);
    expect(graph.addEdge(1, 2), isFalse);
  });

  test('flagEdges', () {
    final g = Graph.fromEdges([
      [1, 2],
      [1, 3],
      [2, 4],
      [3, 4],
      [1, 5],
      [5, 7],
      [7, 1]
    ]);

    expect(() => g.flagEdges(null, null), throwsArgumentError);

    final from1 = g.flagEdges([1], null);
    final to7 = g.flagEdges(null, [7]);
    final from2or3to4 = g.flagEdges([2, 3], [4]);

    expect(g.flagEdges([1], [7]), isNull);

    expect(g.edgeFor(1, 2).flags.single, from1);
    expect(g.edgeFor(1, 3).flags.single, from1);
    expect(g.edgeFor(2, 4).flags.single, from2or3to4);
    expect(g.edgeFor(3, 4).flags.single, from2or3to4);
    expect(g.edgeFor(1, 5).flags.single, from1);
    expect(g.edgeFor(5, 7).flags.single, to7);
    expect(g.edgeFor(7, 1).flags, isEmpty);
  });

  test('connected components', () {
    final g = Graph.fromEdges([
      [1, 2],
      [2, 5],
      [5, 1],
      [2, 6],
      [5, 6],
      [2, 3],
      [6, 7],
      [7, 6],
      [3, 7],
      [3, 4],
      [4, 3],
      [4, 8],
      [8, 4],
      [8, 7],
      [8, 9]
    ]);

    final comps = g.flagConnectedComponents();

    expect(comps, hasLength(4));

    final s125 = comps.values
        .singleWhere((s) => s.difference(Set.from([1, 2, 5])).isEmpty);
    final s348 = comps.values
        .singleWhere((s) => s.difference(Set.from([3, 4, 8])).isEmpty);
    final s67 =
        comps.values.singleWhere((s) => s.difference(Set.from([6, 7])).isEmpty);

    expect(comps[null], Set.from([9]));

    expect(s125, isNot(s348));
    expect(s348, isNot(s67));
    expect(s67, isNot(s125));
  });

  group('style', () {
    test('nodes and edges', () {
      final g = Graph.fromEdges([
        [1, 2],
        [1, 3],
        [2, 4],
        [3, 4],
        [1, 5],
        [5, 7],
        [7, 1]
      ]);

      g.flagPath(1, 4);

      gExpect(g.createGviz(graphStyle: GStyle()), r'''digraph the_graph {
  "1" [label="1", color=red];
  "2" [label="2"];
  "1" -> "2" [color=blue];
  "3" [label="3", color=red];
  "1" -> "3" [color=blue];
  "4" [label="4"];
  "2" -> "4" [color=blue];
  "3" -> "4" [color=blue];
  "5" [label="5", color=red];
  "1" -> "5";
  "7" [label="7", color=red];
  "5" -> "7";
  "7" -> "1";
}
''');
    });
  });

  group('flagEdges', () {
    test('simple', () {
      final graph = Graph()..addEdge(1, 2);

      final flag = graph.flagPath(1, 2);

      expect(flag, isNotNull);

      expect(graph.edges, hasLength(1));
      expect(graph.edges.single.flags.single, flag);
    });

    test('empty', () {
      final graph = Graph();

      final flag = graph.flagPath(1, 2);

      expect(flag, isNull);

      expect(graph.edges, isEmpty);
    });

    test('no match', () {
      final graph = Graph()..addEdge(1, 2);

      final flag = graph.flagPath(1, 3);

      expect(flag, isNull);

      expect(graph.edges, hasLength(1));
      expect(graph.edges.single.flags, isEmpty);
    });

    test('1-2-3', () {
      final graph = Graph.fromEdges([
        [1, 2],
        [2, 3]
      ]);
      expect(graph.edges, hasLength(2));

      final flag = graph.flagPath(1, 3);

      expect(flag, isNotNull);
      expect(graph.edgeFor(1, 2).flags.single, flag);
      expect(graph.edgeFor(2, 3).flags.single, flag);
    });

    test('1-2-3-1', () {
      final graph = Graph.fromEdges([
        [1, 2],
        [2, 3],
        [3, 1]
      ]);
      expect(graph.edges, hasLength(3));

      final flag = graph.flagPath(1, 3);

      expect(flag, isNotNull);
      expect(graph.edgeFor(1, 2).flags.single, flag);
      expect(graph.edgeFor(2, 3).flags.single, flag);
      expect(graph.edgeFor(3, 1).flags, isEmpty);
    });

    test('diamond', () {
      final graph = Graph.fromEdges([
        [1, 2],
        [2, 4],
        [1, 3],
        [3, 4],
        [4, 5], // not interesting
        [0, 1], // not interesting
        [1, 5], // not interesting
      ]);
      expect(graph.edges, hasLength(7));

      final flag = graph.flagPath(1, 4);

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
      final graph = Graph.fromEdges([
        [1, 2],
        [2, 4],
        [1, 3],
        [3, 4],
        [4, 5],
        [0, 1], // not interesting
        [1, 5],
      ]);
      expect(graph.edges, hasLength(7));

      final flag = graph.flagPath(1, 5);

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
      final graph = Graph.fromEdges([
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

      final flag = graph.flagPath(1, 5);

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
      final graph = Graph()..addEdge(1, 2)..addEdge(1, 3)..addEdge(2, 3);

      final gviz = graph.createGviz();

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
      final graph = Graph()
        ..addEdge(1, 2)
        ..addEdge(1, 3)
        ..addEdge(2, 3)
        ..addEdge('1', 1)
        ..addEdge('2', '1');

      final gviz = graph.createGviz();

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

class GStyle extends GraphStyle {
  @override
  Map<String, String> styleForNode(Object node) {
    final props = super.styleForNode(node);
    if (node is int && node % 2 == 1) {
      props['color'] = 'red';
    }

    return props;
  }

  @override
  Map<String, String> styleForEdge(Edge edge) {
    final props = <String, String>{};

    if (edge.flags.isNotEmpty) {
      props['color'] = 'blue';
    }

    return props;
  }
}
