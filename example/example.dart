// Copyright (c) 2017, Kevin Moore. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:gviz/gviz.dart';

void main() {
  final graph = Gviz();

  for (var item in [
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
  ]) {
    final from = item[0].toString();
    final to = item[1].toString();

    if (item[0] % 2 == 1 && !graph.nodeExists(from)) {
      graph.addNode(from, properties: {'color': 'red'});
    }

    graph.addEdge(from, to);
  }

  print(graph);
}
