import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const livitAppleMapView = "LivitAppleMapView";

class LivitMapView extends StatefulWidget {
  final Function(Map<dynamic, dynamic>) onLocationSelected;
  final double latitude;
  final double longitude;

  const LivitMapView({
    super.key,
    required this.onLocationSelected,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<LivitMapView> createState() => LivitMapViewState();
}

class LivitMapViewState extends State<LivitMapView> {
  MethodChannel? _channel;

  Future<dynamic> _onLocationSelected(MethodCall call) async {
    if (call.method == 'locationSelected') {
      final Map<dynamic, dynamic> arguments = call.arguments;
      widget.onLocationSelected(arguments);
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setInitialLocation();
    });
  }

  Future<void> _setInitialLocation() async {
    if (_channel != null) {
      await _channel!.invokeMethod('setLocation', {
        'latitude': widget.latitude,
        'longitude': widget.longitude,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return const Center(child: Text('Android map coming soon'));
    }

    return UiKitView(
      viewType: livitAppleMapView,
      onPlatformViewCreated: (int id) {
        _channel = MethodChannel('${livitAppleMapView}_$id');
        _channel?.setMethodCallHandler(_onLocationSelected);
        _setInitialLocation();
      },
    );
  }
}
