// Copyright (c) 2017, Kevin Moore. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:gviz/gviz.dart';

void main() {
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
    [8, 7]
  ]);

  g.flagConnectedComponents();

  print(g.createGviz(graphStyle: GStyle()));
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
