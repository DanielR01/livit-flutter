import 'package:flutter/material.dart';
import 'package:livit/cloud_models/location.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/utilities/map_viewer.dart';

class MapLocationPrompt extends StatefulWidget {
  final List<Location> locations;
  const MapLocationPrompt({super.key, required this.locations});

  @override
  State<MapLocationPrompt> createState() => _MapLocationPromptState();
}

class _MapLocationPromptState extends State<MapLocationPrompt> {
  double? selectedLatitude;
  double? selectedLongitude;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LivitText(
            'Selecciona tu ubicación en el mapa dejando presionado. Intenta ser lo más preciso posible, esta ubicación la veran tus clientes.'),
        LivitSpaces.m,
        Flexible(
          child: Container(
            clipBehavior: Clip.hardEdge,
            decoration: LivitContainerStyle.decoration,
            child: LivitMapView(
              initialAddress: widget.locations.first.address!,
              onLocationSelected: (location) {
                setState(() {
                  selectedLatitude = location['latitude'];
                  selectedLongitude = location['longitude'];
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}
