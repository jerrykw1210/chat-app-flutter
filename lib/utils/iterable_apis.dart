import 'dart:core';

extension IterableExtensions<T> on Iterable<T> {
  bool get areAllNull {
    for (final value in this) {
      if (value != null) {
        return false;
      }
    }
    return true;
  }

  bool get areAllNullOrEmpty {
    for (final value in this) {
      if (value == null) {
        continue;
      }
      if (value is Iterable) {
        if (value.isNotEmpty) {
          return false;
        }
      } else if (value is Map) {
        if (value.isNotEmpty) {
          return false;
        }
      } else {
        return false;
      }
    }
    return true;
  }

  bool get areAllNullOrNonNull {
    final isFirstValueNull = first == null;
    for (final value in this) {
      if ((value == null) != isFirstValueNull) {
        return false;
      }
    }
    return true;
  }

  T? firstWhereOrNull(bool Function(T element) test) {
    try {
      return firstWhere(test);
    } catch (e) {
      print(e);
      return null; // Return null if no element is found
    }
  }
}
