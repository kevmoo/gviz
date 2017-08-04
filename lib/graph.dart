class Graph {
  final _edges = new Set<_Edge>();

  bool addEdge(Object a, Object b) => _edges.add(new _Edge(a, b));
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
