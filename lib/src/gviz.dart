// Copyright (c) 2017, Kevin Moore. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

class Gviz {
  static const _keywords = const [
    'node',
    'edge',
    'graph',
    'digraph',
    'subgraph',
    'strict'
  ];

  static final _validName = new RegExp(r'^[a-zA-Z_][a-zA-Z_\d]*$');

  final String _name;
  final Map<String, String> _nodeProperties;
  final Map<String, String> _edgeProperties;

  final _items = <_Item>[];

  Gviz(
      {String name,
      Map<String, String> nodeProperties,
      Map<String, String> edgeProperties})
      : this._name = name ?? 'the_graph',
        this._edgeProperties = edgeProperties ?? const {},
        this._nodeProperties = nodeProperties ?? const {} {
    if (!_validName.hasMatch(this._name)) {
      throw new ArgumentError.value(
          name, 'name', '`name` must be a simple name.');
    }
  }

  void addNode(String name, {Map<String, String> properties}) {
    if (_items.any((item) => item is _Node && item.name == name)) {
      throw new ArgumentError.value(
          name, 'name', 'Cannot have more than one node with name `$name`.');
    }
    _items.add(new _Node(name, properties));
  }

  void addEdge(String from, String to, {Map<String, String> properties}) {
    _items.add(new _Edge(from, to, properties));
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
        var props = properties.keys
            .map((key) => '$key=${_escape(properties[key])}')
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
    _writeGlobalProperties('node', _nodeProperties);
    _writeGlobalProperties('edge', _edgeProperties);

    void _writeNode(_Node node) {
      var entry = _escape(node.name);
      sink.write('  $entry');
      _writeProps(node.properties);
      sink.writeln(';');
    }

    void _writeEdge(_Edge edge) {
      var entry = _escape(edge.from);
      sink.write('  $entry -> ${_escape(edge.to)}');
      _writeProps(edge.properties);
      sink.writeln(';');
    }

    for (var item in _items) {
      if (item is _Edge) {
        _writeEdge(item);
      } else if (item is _Node) {
        _writeNode(item);
      } else {
        throw new StateError('Unsupported - ${item.runtimeType} - $item');
      }
    }
    sink.writeln('}');
  }

  @override
  String toString() {
    var buffer = new StringBuffer();
    write(buffer);
    return buffer.toString();
  }
}

abstract class _Item {
  final Map<String, String> properties;

  _Item(Map<String, String> values) : this.properties = values ?? const {};
}

class _Node extends _Item {
  final String name;

  _Node(this.name, Map<String, String> properties) : super(properties);
}

class _Edge extends _Item {
  final String from;
  final String to;

  _Edge(this.from, this.to, Map<String, String> properties) : super(properties);
}
