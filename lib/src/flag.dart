// Copyright (c) 2017, Kevin Moore. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

class Flag {}

class FlagImpl extends Flag {
  final int _id;

  FlagImpl(this._id);

  @override
  String toString() => 'EdgeFlag:$_id';
}
