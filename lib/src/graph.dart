// Copyright (c) 2017, Kevin Moore. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'gviz.dart';

class Graph {
  final _edges = new Set<_Edge>();

  bool addEdge(Object a, Object b) => _edges.add(new _Edge(a, b));

  Gviz createGviz() {
    var gviz = new Gviz();

    var nodeIds = <Object, String>{};

    String addNode(Object node) => nodeIds.putIfAbsent(node, () {
          for (var option in _validIds(node)) {
            if (!nodeIds.values.contains(option)) {
              gviz.addNode(option, properties: {'label': node.toString()});
              return option;
            }
          }

          throw new UnsupportedError(
              'Need to figure out another ID for `$node`, I guess...');
        });

    for (var edge in _edges) {
      var idA = addNode(edge.a);
      var idB = addNode(edge.b);

      gviz.addEdge(idA, idB);
    }

    return gviz;
  }
}

Iterable<String> _validIds(Object node) sync* {
  yield node.toString();

  var start = 1;
  while (true) {
    yield '${node}_${(start++).toString().padLeft(2, '0')}';
  }
}

class _Edge {
  final Object a;
  final Object b;

  _Edge(this.a, this.b);

  @override
  bool operator ==(Object other) =>
      other is _Edge && this.a == other.a && this.b == other.b;

  @override
  int get hashCode => a.hashCode ^ b.hashCode * 37;

  @override
  String toString() => 'Edge: `$a` -> `$b`';
}
