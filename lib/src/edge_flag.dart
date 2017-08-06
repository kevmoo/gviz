// Copyright (c) 2017, Kevin Moore. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

class EdgeFlag {}

class EdgeFlagImpl extends EdgeFlag {
  final int _id;

  EdgeFlagImpl(this._id);

  @override
  String toString() => 'EdgeFlag:$_id';
}
