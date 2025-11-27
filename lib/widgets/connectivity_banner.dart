import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

/// Displays a persistent warning banner whenever the device loses connectivity.
class ConnectivityBanner extends StatefulWidget {
  final Widget child;

  const ConnectivityBanner({super.key, required this.child});

  @override
  State<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner> {
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  StreamSubscription<InternetStatus>? _internetSubscription;
  final InternetConnection _connectionChecker = InternetConnection();
  bool _isOffline = false;
  bool _transportOffline = false;
  bool _internetOffline = false;

  @override
  void initState() {
    super.initState();
    _listenToConnectivity();
  }

  void _listenToConnectivity() {
    final connectivity = Connectivity();
    connectivity.checkConnectivity().then(_handleConnectivity).catchError((_) {});
    _subscription = connectivity.onConnectivityChanged.listen(_handleConnectivity);

    _connectionChecker.hasInternetAccess.then(
      (hasInternet) => _handleInternetStatus(
        hasInternet ? InternetStatus.connected : InternetStatus.disconnected,
      ),
    );
    _internetSubscription = _connectionChecker.onStatusChange.listen(_handleInternetStatus);
  }

  void _handleConnectivity(List<ConnectivityResult> results) {
    _transportOffline = !_hasUsableInterface(results);
    _refreshOfflineState();
  }

  void _handleInternetStatus(InternetStatus status) {
    _internetOffline = status == InternetStatus.disconnected;
    _refreshOfflineState();
  }

  bool _hasUsableInterface(List<ConnectivityResult> results) {
    if (results.isEmpty) return false;
    if (results.any((result) => result == ConnectivityResult.none)) {
      return false;
    }

    for (final result in results) {
      switch (result) {
        case ConnectivityResult.wifi:
        case ConnectivityResult.mobile:
        case ConnectivityResult.ethernet:
          return true;
        default:
          break;
      }
    }
    return false;
  }

  void _refreshOfflineState() {
    final newValue = _transportOffline || _internetOffline;
    if (!mounted || newValue == _isOffline) return;
    setState(() => _isOffline = newValue);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _internetSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: IgnorePointer(
            ignoring: true,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 250),
              offset: _isOffline ? Offset.zero : const Offset(0, -1),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 250),
                opacity: _isOffline ? 1 : 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(12),
                      color: Theme.of(context).colorScheme.error,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.wifi_off, color: Colors.white),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'No tienes conexión, o la calidad de tu red está degradada; la aplicación podría no funcionar adecuadamente.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
