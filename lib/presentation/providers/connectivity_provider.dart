import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityStatusProvider = StreamProvider<List<ConnectivityResult>>((
  ref,
) {
  final connectivity = Connectivity();
  return connectivity.onConnectivityChanged;
});

final isLocalMeshOnlyProvider = Provider<bool>((ref) {
  final status = ref.watch(connectivityStatusProvider).valueOrNull;
  if (status == null || status.isEmpty) return false;
  // If no internet connection (only none or unsupported), it operates in Local Mesh mode
  return status.contains(ConnectivityResult.none);
});
