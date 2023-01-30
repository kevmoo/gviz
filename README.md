[![Pub Package](https://img.shields.io/pub/v/gviz.svg)](https://pub.dev/packages/gviz)
[![CI](https://github.com/kevmoo/gviz/workflows/CI/badge.svg?branch=master)](https://github.com/kevmoo/gviz/actions?query=workflow%3ACI+branch%3Amaster)

A simple Dart package for writing
[Graphviz](http://www.graphviz.org/)
[dot files](http://www.graphviz.org/doc/info/lang.html).

```
final graph = Gviz()
      ..addNode('solo')
      ..addEdge('solo', 'solo');
print(graph);
```

This will produce:

```
digraph the_graph {
  solo;
  solo -> solo;
}
```

To create undirected graphs, use the constructor parameter like so: `Gviz(isDirected:false)`.
