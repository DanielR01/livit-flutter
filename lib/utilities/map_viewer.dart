import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const livitAppleMapView = "LivitAppleMapView";

class LivitAppleMapView extends StatefulWidget {
  final Function(Map<dynamic, dynamic>) onLocationSelected;

  const LivitAppleMapView({super.key, required this.onLocationSelected});

  @override
  State<LivitAppleMapView> createState() => _LivitAppleMapViewState();
}

class _LivitAppleMapViewState extends State<LivitAppleMapView> {

  Future<dynamic> _onLocationSelected(MethodCall call) async {
    if (call.method == 'locationSelected') {
      final Map<dynamic, dynamic> arguments = call.arguments;
      widget.onLocationSelected(arguments);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> creationParams = <String, dynamic>{};

    if (Platform.isAndroid) {
      // TODO: Implement Android map view
      return const Center(child: Text('Android map coming soon'));
    }

    return UiKitView(
      viewType: livitAppleMapView,
      layoutDirection: TextDirection.ltr,
      creationParams: creationParams,
      creationParamsCodec: const StandardMessageCodec(),
      onPlatformViewCreated: (int id) {
        final channel = MethodChannel('${livitAppleMapView}_$id');
        channel.setMethodCallHandler(_onLocationSelected);
      },
    );
  }
}
