// Copyright (c) 2017, Kevin Moore. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:collection';

import 'package:collection/collection.dart';

import 'edge.dart';
import 'edge_flag.dart';
import 'graph_style.dart';
import 'gviz.dart';

class Graph<T> {
  int _count = 0;
  final _edges = new Set<EdgeImpl<T>>();

  Graph();

  factory Graph.fromEdges(Iterable<List<T>> edges) {
    var graph = new Graph<T>();

    for (var e in edges) {
      if (e.length != 2) {
        throw new ArgumentError('All values in `edges` must have length `2`.');
      }

      graph.addEdge(e[0], e[1]);
    }

    return graph;
  }

  Set<Edge> get edges => new UnmodifiableSetView<Edge>(_edges);

  bool addEdge(T from, T to) => _edges.add(new EdgeImpl(from, to));

  Edge<T> edgeFor(T from, T to) => _edges
      .firstWhere((e) => e.from == from && e.to == to, orElse: () => null);

  Map<EdgeFlag, Set<T>> flagConnectedComponents() {
    var connectedComps = stronglyConnectedComponents(_mapView());

    var map = <EdgeFlag, Set<T>>{};

    for (var component in connectedComps) {
      map[flagEdges(component, component)] = component;
    }

    return map;
  }

  EdgeFlag flagPath(T from, T to) => _flagPath(from, to, null);

  EdgeFlag _flagPath(T from, T to, EdgeFlag flag) {
    EdgeFlag gf() => flag ??= new EdgeFlagImpl(_count++);

    var queue = new Queue();

    EdgeFlag flagHelper(Object from, Object to) {
      assert(from != to, 'Not doing loops for now...');
      assert(!queue.contains(to));

      EdgeFlag helperFlag;

      if (queue.contains(from)) {
        // loop!
        return null;
      }
      queue.add(from);

      try {
        for (var edge in _edges.where((e) => e.from == from)) {
          if (flag != null && edge.flags.contains(flag)) {
            // we've already been here! return the flag!
            return flag;
          }
          if (edge.from == from && edge.to == to) {
            // this had better be the first time, right?
            flag = helperFlag = gf();
            edge.addFlag(helperFlag);
          } else {
            // must go deeper
            var deepFlag = flagHelper(edge.to, to);
            if (deepFlag != null) {
              if (helperFlag == null) {
                helperFlag = deepFlag;
              }
              assert(helperFlag == deepFlag);
              assert(deepFlag == flag);
              // There is a path from `edge.to` to the target `to`,
              // so there is also a path from `edge.from` to `to`
              // so add it!
              edge.addFlag(deepFlag);
            }
          }
        }
      } finally {
        assert(queue.last == from);
        queue.removeLast();
      }

      return helperFlag;
    }

    return flagHelper(from, to);
  }

  /// If [from] is `null`, then all edges entering [to] are flagged.
  /// Likewise, if [to] is `null`, all edges leaving [from] are flagged.
  EdgeFlag flagEdges(Iterable<T> from, Iterable<T> to) {
    if (to == null && from == null) {
      throw new ArgumentError('`to` and `from` cannot both be `null`.');
    }

    EdgeFlag flag;
    EdgeFlag gf() => flag ??= new EdgeFlagImpl(_count++);

    for (var edge in _edges) {
      if (from != null && !from.contains(edge.from)) {
        continue;
      }

      if (to != null && !to.contains(edge.to)) {
        continue;
      }

      edge.addFlag(gf());
    }

    return flag;
  }

  Gviz createGviz({GraphStyle graphStyle}) {
    graphStyle ??= new GraphStyle();
    var gviz = new Gviz();

    var nodeIds = <Object, String>{};

    String addNode(Object node) => nodeIds.putIfAbsent(node, () {
          for (var option in _validIds(node)) {
            if (!nodeIds.values.contains(option)) {
              gviz.addNode(option, properties: graphStyle.styleForNode(node));
              return option;
            }
          }

          throw new UnsupportedError(
              'Need to figure out another ID for `$node`, I guess...');
        });

    for (var edge in _edges) {
      var idA = addNode(edge.from);
      var idB = addNode(edge.to);

      gviz.addEdge(idA, idB, properties: graphStyle.styleForEdge(edge));
    }

    return gviz;
  }

  Map<T, Set<T>> _mapView() {
    var map = <T, Set<T>>{};

    for (var edge in _edges) {
      map.putIfAbsent(edge.from, () => new Set<T>()).add(edge.to);
    }

    return map;
  }
}

Iterable<String> _validIds(Object node) sync* {
  yield node.toString();

  var start = 1;
  while (true) {
    yield '${node}_${(start++).toString().padLeft(2, '0')}';
  }
}
