import 'package:ardennes/libraries/extensions/scoped.dart';

extension NullAware<T> on Iterable<T> {
  T? firstOrNull() {
    if (isEmpty) {
      return null;
    } else {
      return first;
    }
  }

  T? getOrNull(int index) {
    if (index >= length) {
      return null;
    } else {
      return elementAt(index);
    }
  }

  Iterable<E> mapNotNull<E>(E? Function(T t) f) =>
      expand((t) => f(t)?.let((v) => [v]) ?? ([] as List<E>));

  Iterable<E> mapWithIndex<E>(E Function(int i, T) callback) =>
      Iterable.generate(length, (index) => callback(index, elementAt(index)));
}
