abstract class GvizItem {}

class Node implements GvizItem {
  final String name;
  final Map<String, String> properties;

  Node(this.name, Map<String, String> properties)
      : properties = properties ?? const {};
}

class Edge implements GvizItem {
  final String from;
  final String to;
  final Map<String, String> properties;

  Edge(this.from, this.to, Map<String, String> properties)
      : properties = properties ?? const {};
}

class Blank implements GvizItem {
  const Blank();
}
