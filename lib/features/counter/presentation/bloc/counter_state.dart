class CounterState {
  final int counter;

  const CounterState({required this.counter});

  CounterState copyWith({int? counter}) {
    return CounterState(counter: counter ?? this.counter);
  }
}