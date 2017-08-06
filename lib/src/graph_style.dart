// Copyright (c) 2017, Kevin Moore. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'edge.dart';

class GraphStyle {
  Map<String, String> styleForEdge(Edge edge) => <String, String>{};
  Map<String, String> styleForNode(Object node) =>
      <String, String>{'label': node.toString()};
}
