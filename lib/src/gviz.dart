import 'item.dart';

class Gviz {
  final String _name;
  final Map<String, String> _nodeProperties;
  final Map<String, String> _edgeProperties;
  final Map<String, String> _graphProperties;

  final _items = <GvizItem>[];

  Gviz(
      {String name,
      Map<String, String> nodeProperties,
      Map<String, String> edgeProperties,
      Map<String, String> graphProperties})
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
      _items.whereType<Node>().any((item) => item.name == nodeName);

  void addNode(String name, {Map<String, String> properties}) {
    if (nodeExists(name)) {
      throw ArgumentError.value(
          name, 'name', 'Cannot have more than one node with name `$name`.');
    }
    _items.add(Node(name, properties));
  }

  void addEdge(String from, String to, {Map<String, String> properties}) {
    _items.add(Edge(from, to, properties));
  }

  /// Adds a blank line to the output contents.
  ///
  /// Not to be confused with [addEdge] – does not affect the rendered graph.
  void addBlankLine() {
    _items.add(const Blank());
  }

  void write(StringSink sink) {
    void _writeProps(Map<String, String> properties) {
      if (properties.isNotEmpty) {
        final props = properties.keys
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
    _writeGlobalProperties('graph', _graphProperties);
    _writeGlobalProperties('node', _nodeProperties);
    _writeGlobalProperties('edge', _edgeProperties);

    void _writeNode(Node node) {
      final entry = _escape(node.name);
      sink.write('  $entry');
      _writeProps(node.properties);
      sink.writeln(';');
    }

    void _writeEdge(Edge edge) {
      final entry = _escape(edge.from);
      sink.write('  $entry -> ${_escape(edge.to)}');
      _writeProps(edge.properties);
      sink.writeln(';');
    }

    for (var item in _items) {
      if (item is Edge) {
        _writeEdge(item);
      } else if (item is Node) {
        _writeNode(item);
      } else if (item is Blank) {
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

String _escape(String input) {
  if (_validName.hasMatch(input) && !_keywords.contains(input.toLowerCase())) {
    return input;
  }

  return '"${input.replaceAll('"', '\\"')}"';
}

const _keywords = ['node', 'edge', 'graph', 'digraph', 'subgraph', 'strict'];

final _validName = RegExp(r'^[a-zA-Z_][a-zA-Z_\d]*$');
