import 'package:flutter/foundation.dart';

/// Tracks which of the 4 bottom-nav tabs (Toy/Journey/Care/Brand) is
/// currently selected. (Planet was removed.)
class NavProvider extends ChangeNotifier {
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  void setIndex(int i) {
    if (_currentIndex == i) return;
    _currentIndex = i;
    notifyListeners();
  }
}
