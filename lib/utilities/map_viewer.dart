import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const livitAppleMapView = "LivitAppleMapView";

class LivitMapView extends StatefulWidget {
  final Function(Map<dynamic, dynamic>) onLocationSelected;
  final Map<String, double?> hoverCoordinates;
  final GeoPoint? locationCoordinates;
  final bool shouldUpdate;
  final bool shouldReinitialize;
  final bool shouldRemoveAnnotation;
  final Function() onUpdate;
  final bool shouldUseUserLocation;

  const LivitMapView({
    super.key,
    required this.onLocationSelected,
    required this.hoverCoordinates,
    this.locationCoordinates,
    this.shouldUpdate = false,
    this.shouldReinitialize = false,
    required this.onUpdate,
    this.shouldRemoveAnnotation = false,
    this.shouldUseUserLocation = false,
  });

  @override
  State<LivitMapView> createState() => LivitMapViewState();
}

class LivitMapViewState extends State<LivitMapView> {
  MethodChannel? _channel;
  Key _viewKey = UniqueKey();

  @override
  void didUpdateWidget(LivitMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldReinitialize) {
      setState(() {
        _viewKey = UniqueKey();
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onUpdate.call();
      });
      if (widget.shouldUpdate) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _update();
        });
      }
    } else if (widget.shouldUpdate || widget.shouldRemoveAnnotation) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _update();
      });
    }
  }

  Future<void> _update() async {
    _hoverLocation();
    if (widget.locationCoordinates != null) {
      _setLocation();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onUpdate.call();
      });
    }
  }

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
  }

  Future<void> _hoverLocation() async {
    if (_channel != null &&
        widget.hoverCoordinates['latitude'] != null &&
        widget.hoverCoordinates['longitude'] != null &&
        !widget.shouldUseUserLocation) {
      await _channel!.invokeMethod('hoverLocation', {
        'latitude': widget.hoverCoordinates['latitude'],
        'longitude': widget.hoverCoordinates['longitude'],
      });
    } else if (_channel != null && widget.shouldUseUserLocation) {
      await _channel!.invokeMethod('useUserLocation');
    }
  }

  Future<void> _setLocation() async {
    if (_channel != null && widget.locationCoordinates != null) {
      await _channel!.invokeMethod('setLocation', {
        'latitude': widget.locationCoordinates!.latitude,
        'longitude': widget.locationCoordinates!.longitude,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return const Center(child: Text('Android map coming soon'));
    }

    return UiKitView(
      key: _viewKey,
      viewType: livitAppleMapView,
      onPlatformViewCreated: (int id) {
        _channel = MethodChannel('${livitAppleMapView}_$id');
        _channel?.setMethodCallHandler(_onLocationSelected);
      },
    );
  }
}
