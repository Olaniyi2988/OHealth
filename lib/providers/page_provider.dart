import 'package:flutter/material.dart';

class PageProvider extends ChangeNotifier {
  Page _currentPage;
  List<Page> _pageStack = [];

  PageProvider() {
    _currentPage = Page.DASHBOARD;
  }

  Page getCurrentPage() {
    return _currentPage;
  }

  bool canPop() {
    if (_pageStack.length == 0) {
      return false;
    }
    return true;
  }

  void setCurrentPage(Page page) {
    _pageStack.add(_currentPage);
    _currentPage = page;
    notifyListeners();
  }

  void goBack() {
    if (_pageStack.length > 0) {
      _currentPage = _pageStack.removeLast();
      notifyListeners();
    }
  }
}

enum Page {
  DASHBOARD,
  PATIENTS,
  LAB,
  REGISTRATION,
  APPOINTMENT,
  NOTIFICATIONS,
  SETTINGS,
  ANALYTICS
}
