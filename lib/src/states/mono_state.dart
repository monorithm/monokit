/// States shared by Monokit interactive components.
enum MonoState {
  hovered,
  focused,
  focusVisible,
  pressed,
  disabled,
  invalid,
  checked,
  selected,
  expanded,
  open,
  active,
}

/// Resolves a value from a set of [MonoState]s.
class MonoStateProperty<T> {
  const MonoStateProperty(this._resolver);

  final T Function(Set<MonoState> states) _resolver;

  T resolve(Set<MonoState> states) =>
      _resolver(Set<MonoState>.unmodifiable(states));

  static MonoStateProperty<T> all<T>(T value) =>
      MonoStateProperty<T>((_) => value);
}
