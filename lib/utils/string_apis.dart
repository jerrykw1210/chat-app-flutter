
import 'package:fixnum/fixnum.dart';

/// Extension on [String] which provides some useful methods.
///
/// This class provides methods to check if a string is blank, parse a string to
/// an integer and parse a string to a double.
extension StringExtention on String {
  /// Checks if a string is blank.
  ///
  /// A string is blank if it's either null or empty after trimming.
  bool get isBlank => trim().isEmpty;

  /// Parses a string to an integer.
  ///
  /// This method will throw a [FormatException] if the string is not a valid
  /// integer.
  int parseInt() {
    return int.parse(this);
  }

  /// Parses a string to a double.
  ///
  /// This method will throw a [FormatException] if the string is not a valid
  /// double.
  double parseDouble() {
    return double.parse(this);
  }

  /// Parses a string to an Int64.
  ///
  /// This method will throw a [FormatException] if the string is not a valid
  /// 64-bit integer.
  Int64 parseInt64() {
    return Int64.parseInt(this);
  }
}
