import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

const livitAppleMapPrompt = "LivitAppleMapPrompt";

class LivitMapPrompt extends StatefulWidget {
  final Function(Map<dynamic, dynamic>) onLocationSelected;
  final Map<String, double?> hoverCoordinates;
  final GeoPoint? locationCoordinates;
  final bool shouldUpdate;
  final bool shouldReinitialize;
  final bool shouldRemoveAnnotation;
  final Function() onUpdate;
  final bool shouldUseUserLocation;
  final double zoom;
  final bool shouldZoomToUserLocation;

  const LivitMapPrompt({
    super.key,
    required this.onLocationSelected,
    required this.hoverCoordinates,
    this.locationCoordinates,
    this.shouldUpdate = false,
    this.shouldReinitialize = false,
    required this.onUpdate,
    this.shouldRemoveAnnotation = false,
    this.shouldUseUserLocation = false,
    required this.zoom,
    this.shouldZoomToUserLocation = false,
  });

  @override
  State<LivitMapPrompt> createState() => LivitMapPromptState();
}

class LivitMapPromptState extends State<LivitMapPrompt> {
  MethodChannel? _channel;
  Key _viewKey = UniqueKey();
  LatLng? _initialTarget;

  late GoogleMapController mapController;
  bool _isGoogleMapCreated = false;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _isGoogleMapCreated = true;
  }

  @override
  void didUpdateWidget(LivitMapPrompt oldWidget) {
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
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    debugPrint('🏁 [LivitMapViewState] Initializing location');
    if (widget.locationCoordinates != null) {
      debugPrint('🏁 [LivitMapViewState] Setting location to widget.locationCoordinates');
      setState(() {
        _initialTarget = LatLng(widget.locationCoordinates!.latitude, widget.locationCoordinates!.longitude);
      });
      return;
    }

    try {
      debugPrint('🏁 [LivitMapViewState] Checking location permission');
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('🏁 [LivitMapViewState] Requesting location permission');
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        debugPrint('🏁 [LivitMapViewState] Location permission denied');
        setState(() {
          _initialTarget = const LatLng(0, 0);
        });
        return;
      }

      debugPrint('🏁 [LivitMapViewState] Getting current position');
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _initialTarget = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      debugPrint('🏁 [LivitMapViewState] Error getting location: $e');
      setState(() {
        _initialTarget = const LatLng(0, 0);
      });
    }
  }

  Future<void> _hoverLocation() async {
    debugPrint('🏁 [LivitMapViewState] Hovering location with zoom: ${widget.zoom}');
    if (Platform.isIOS) {
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
    } else if (Platform.isAndroid) {
      if (!_isGoogleMapCreated) {
        await Future.delayed(const Duration(milliseconds: 2000));
        if (!_isGoogleMapCreated) {
          return;
        }
      }
      if (widget.hoverCoordinates['latitude'] != null && widget.hoverCoordinates['longitude'] != null) {
        mapController.animateCamera(
            CameraUpdate.newLatLngZoom(LatLng(widget.hoverCoordinates['latitude']!, widget.hoverCoordinates['longitude']!), widget.zoom));
      }
    }
  }

  Future<void> _setLocation() async {
    debugPrint('🏁 [LivitMapViewState] Setting location');
    if (Platform.isIOS) {
      debugPrint('🏁 [LivitMapViewState] Setting location on iOS');
      if (_channel != null && widget.locationCoordinates != null) {
        await _channel!.invokeMethod('setLocation', {
          'latitude': widget.locationCoordinates!.latitude,
          'longitude': widget.locationCoordinates!.longitude,
        });
      }
    } else if (Platform.isAndroid) {
      if (widget.locationCoordinates != null) {
        mapController.animateCamera(
            CameraUpdate.newLatLngZoom(LatLng(widget.locationCoordinates!.latitude, widget.locationCoordinates!.longitude), 16));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_initialTarget == null) {
      debugPrint('🏁 [LivitMapViewState] Initial target is null');
      return const Center(child: CircularProgressIndicator());
    }

    if (Platform.isAndroid) {
      debugPrint('🏁 [LivitMapViewState] Building Android map');
      return GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _initialTarget!,
          zoom: widget.zoom,
        ),
        onLongPress: (LatLng point) {
          debugPrint('🏁 [LivitMapViewState] Long press at $point');
          widget.onLocationSelected({'latitude': point.latitude, 'longitude': point.longitude});
        },
        markers: widget.locationCoordinates != null
            ? {
                Marker(
                  markerId: const MarkerId('location'),
                  position: LatLng(widget.locationCoordinates!.latitude, widget.locationCoordinates!.longitude),
                ),
              }
            : {},
      );
    }

    return UiKitView(
      key: _viewKey,
      viewType: livitAppleMapPrompt,
      onPlatformViewCreated: (int id) {
        _channel = MethodChannel('${livitAppleMapPrompt}_$id');
        _channel?.setMethodCallHandler(_onLocationSelected);
      },
    );
  }
}
