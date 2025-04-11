enum InvalidMediaState{
  incorrectFile,
  notExists,
  notReproducible
}

extension ParsePCToString on InvalidMediaState {
  String value() {
    return toString().split('.').last;
  }
}