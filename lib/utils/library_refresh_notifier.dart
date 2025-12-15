import 'package:flutter/material.dart';

class LibraryRefreshNotifier {
  static final ValueNotifier<bool> refresh = ValueNotifier(false);

  static void notify() {
    refresh.value = true;
  }

  static void clear() {
    refresh.value = false;
  }
}
