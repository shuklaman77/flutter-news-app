import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectionStatusController =
  StreamController<bool>.broadcast();

  Stream<bool> get connectionStream => _connectionStatusController.stream;

  ConnectivityService() {
    // Listen to connectivity changes
    _connectivity.onConnectivityChanged.listen((result) {
      // result is a single ConnectivityResult
      final isConnected = result != ConnectivityResult.none;
      _connectionStatusController.add(isConnected);
    });
  }

  // Check current connectivity
  Future<bool> isConnected() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  void dispose() {
    _connectionStatusController.close();
  }
}