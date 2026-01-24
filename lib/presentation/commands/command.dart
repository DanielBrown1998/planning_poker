import 'package:flutter/foundation.dart';

/// Base interface for all commands in the application
abstract class Command<T> {
  Future<T> execute();
}

/// Command that can be observed for loading state and errors
class ObservableCommand<T> extends ChangeNotifier {
  final Future<T> Function() _action;

  bool _isLoading = false;
  String? _error;
  T? _result;

  ObservableCommand(this._action);

  bool get isLoading => _isLoading;
  String? get error => _error;
  T? get result => _result;
  bool get hasError => _error != null;

  Future<T?> execute() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _result = await _action();
      _isLoading = false;
      notifyListeners();
      return _result;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
