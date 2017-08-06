// Copyright (c) 2017, Kevin Moore. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:collection/collection.dart';

import 'edge_flag.dart';

abstract class Edge {
  Object get from;
  Object get to;
  Set<EdgeFlag> get flags;
}

class EdgeImpl implements Edge {
  @override
  final Object from;

  @override
  final Object to;

  final _flags = new Set<EdgeFlag>();

  @override
  Set<EdgeFlag> get flags => new UnmodifiableSetView(_flags);

  EdgeImpl(this.from, this.to);

  void addFlag(EdgeFlag flag) {
    var added = _flags.add(flag);
    assert(added, 'Should never add more than once.');
  }

  @override
  bool operator ==(Object other) =>
      other is Edge && this.from == other.from && this.to == other.to;

  @override
  int get hashCode => from.hashCode ^ to.hashCode * 37;

  @override
  String toString() => 'Edge: `$from` -> `$to`';
}
