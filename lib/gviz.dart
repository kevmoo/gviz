// Copyright (c) 2017, Kevin Moore. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

class Gviz {
  static const _keywords = [
    'node',
    'edge',
    'graph',
    'digraph',
    'subgraph',
    'strict'
  ];

  static final _validName = RegExp(r'^[a-zA-Z_][a-zA-Z_\d]*$');

  final String _name;
  final Map<String, String> _nodeProperties;
  final Map<String, String> _edgeProperties;
  final Map<String, String> _graphProperties;

  final _items = <_Item>[];

  Gviz(
      {String? name,
      Map<String, String>? nodeProperties,
      Map<String, String>? edgeProperties,
      Map<String, String>? graphProperties})
      : _name = name ?? 'the_graph',
        _edgeProperties = edgeProperties ?? const {},
        _nodeProperties = nodeProperties ?? const {},
        _graphProperties = graphProperties ?? const {} {
    if (!_validName.hasMatch(_name)) {
      throw ArgumentError.value(name, 'name', '`name` must be a simple name.');
    }
  }

  /// Returns `true` if [addNode] has been called with [nodeName].
  bool nodeExists(String nodeName) =>
      _items.whereType<_Node>().any((item) => item.name == nodeName);

  void addNode(String name, {Map<String, String>? properties}) {
    if (nodeExists(name)) {
      throw ArgumentError.value(
          name, 'name', 'Cannot have more than one node with name `$name`.');
    }
    _items.add(_Node(name, properties));
  }

  void addEdge(String from, String to, {Map<String, String>? properties}) {
    _items.add(_Edge(from, to, properties));
  }

  /// Adds a blank line to the output contents.
  ///
  /// Not to be confused with [addEdge] – does not affect the rendered graph.
  void addBlankLine() {
    _items.add(const _Blank());
  }

  void write(StringSink sink) {
    String _escape(String input) {
      if (_validName.hasMatch(input) &&
          !_keywords.contains(input.toLowerCase())) {
        return input;
      }

      return '"${input.replaceAll('"', '\\"')}"';
    }

    void _writeProps(Map<String, String> properties) {
      if (properties.isNotEmpty) {
        final props = properties.keys
            .map((key) => '$key=${_escape(properties[key]!)}')
            .toList(growable: false)
            .join(', ');
        sink.write(' [$props]');
      }
    }

    void _writeGlobalProperties(String name, Map<String, String> properties) {
      assert(_keywords.contains(name));
      if (properties.isNotEmpty) {
        sink.write('  $name');
        _writeProps(properties);
        sink.writeln(';');
      }
    }

    sink.writeln('digraph $_name {');
    _writeGlobalProperties('graph', _graphProperties);
    _writeGlobalProperties('node', _nodeProperties);
    _writeGlobalProperties('edge', _edgeProperties);

    void _writeNode(_Node node) {
      final entry = _escape(node.name);
      sink.write('  $entry');
      _writeProps(node.properties);
      sink.writeln(';');
    }

    void _writeEdge(_Edge edge) {
      final entry = _escape(edge.from);
      sink.write('  $entry -> ${_escape(edge.to)}');
      _writeProps(edge.properties);
      sink.writeln(';');
    }

    for (var item in _items) {
      if (item is _Edge) {
        _writeEdge(item);
      } else if (item is _Node) {
        _writeNode(item);
      } else if (item is _Blank) {
        sink.writeln();
      } else {
        throw StateError('Unsupported - ${item.runtimeType} - $item');
      }
    }
    sink.writeln('}');
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    write(buffer);
    return buffer.toString();
  }
}

abstract class _Item {}

class _Node implements _Item {
  final String name;
  final Map<String, String> properties;

  _Node(this.name, Map<String, String>? properties)
      : properties = properties ?? const {};
}

class _Edge implements _Item {
  final String from;
  final String to;
  final Map<String, String> properties;

  _Edge(this.from, this.to, Map<String, String>? properties)
      : properties = properties ?? const {};
}

class _Blank implements _Item {
  const _Blank();
}
