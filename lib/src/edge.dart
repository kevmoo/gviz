// Copyright (c) 2017, Kevin Moore. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:collection/collection.dart';

import 'flag.dart';

abstract class Edge<T> {
  T get from;
  T get to;
  Set<Flag> get flags;
}

class EdgeImpl<T> implements Edge<T> {
  @override
  final T from;

  @override
  final T to;

  final _flags = new Set<Flag>();

  @override
  Set<Flag> get flags => new UnmodifiableSetView(_flags);

  EdgeImpl(this.from, this.to);

  void addFlag(Flag flag) {
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
