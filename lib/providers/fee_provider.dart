import 'package:flutter/foundation.dart';
import '../core/models/student_model.dart';

class FeeProvider with ChangeNotifier {
  final Map<dynamic, bool> _feeMap = {};
  String _currentMonth = 'اگست 2026';

  FeeProvider([dynamic storageService]);

  String get currentMonth => _currentMonth;
  int get paidCount => _feeMap.values.where((v) => v).length;
  int get unpaidCount => _feeMap.values.where((v) => !v).length;

  void ensureFeesExist(List<StudentModel> students) {
    for (var s in students) {
      if (!_feeMap.containsKey(s.id)) {
        _feeMap[s.id] = s.feePaidThisMonth;
      }
    }
  }

  bool isFeePaid(dynamic studentId) {
    return _feeMap[studentId] ?? false;
  }

  void toggleFeeStatus(dynamic studentId) {
    _feeMap[studentId] = !(_feeMap[studentId] ?? false);
    notifyListeners();
  }
}
