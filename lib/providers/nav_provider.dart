import 'package:flutter/foundation.dart';

/// Tracks which of the 5 bottom-nav tabs (Toy/Planet/Journey/Care/Brand)
/// is currently selected.
class NavProvider extends ChangeNotifier {
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  void setIndex(int i) {
    if (_currentIndex == i) return;
    _currentIndex = i;
    notifyListeners();
  }
}
