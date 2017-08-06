// Copyright (c) 2017, Kevin Moore. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:gviz/gviz.dart';

void main() {
  var g = new Graph.fromEdges([
    [1, 2],
    [1, 3],
    [2, 4],
    [3, 4],
    [1, 5],
    [5, 7],
    [7, 1]
  ]);

  g.flagEdge(1, 4);

  print(g.createGviz(graphStyle: new GStyle()));
}

class GStyle extends GraphStyle {
  @override
  Map<String, String> styleForNode(Object node) {
    var props = super.styleForNode(node);
    if (node is int && node % 2 == 1) {
      props['color'] = 'red';
    }

    return props;
  }

  @override
  Map<String, String> styleForEdge(Edge edge) {
    var props = <String, String>{};

    if (edge.flags.isNotEmpty) {
      props['color'] = 'blue';
    }

    return props;
  }
}
