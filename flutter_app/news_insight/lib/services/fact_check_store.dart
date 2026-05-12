import 'package:flutter/material.dart';
import 'api_service.dart';

class FactCheckStore extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  Map<String, dynamic> _currentResult = {};

  Map<String, dynamic> get currentResult => _currentResult;

  Future<void> checkFact(String text) async {
    try {
      final result = await _apiService.analyzeText(text);
      _currentResult = result;
      notifyListeners();
    } catch (e) {
      _currentResult = {'error': e.toString()};
      notifyListeners();
    }
  }

  void clearResult() {
    _currentResult = {};
    notifyListeners();
  }
}