mixin LoadGeneration {
  int _generation = 0;

  int startLoad() => ++_generation;

  int get currentLoad => _generation;

  bool isStale(int ticket) => ticket != _generation;
}
