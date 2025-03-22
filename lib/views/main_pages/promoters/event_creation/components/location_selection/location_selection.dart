import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/styles/bar_style.dart';
import 'package:livit/constants/styles/button_style.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/models/event/event.dart';
import 'package:livit/utilities/bars_containers_fields/bar.dart';
import 'package:livit/utilities/bars_containers_fields/glass_container.dart';
import 'package:livit/utilities/buttons/toggle_button.dart';
import 'package:livit/views/main_pages/promoters/event_creation/components/location_selection/location_selector.dart';

class LocationSelection extends StatefulWidget {
  final List<EventDate> eventDates;

  final ValueChanged<bool> onUseExistingLocationChanged;
  final ValueChanged<String?> onSelectedLocationChanged;
  final ValueChanged<String> onCustomLocationNameChanged;
  final VoidCallback onSelectMapLocation;
  final ValueChanged<bool> onSameLocationForAllDatesChanged;
  final Function(bool isValid)? onValidationChanged;

  const LocationSelection({
    super.key,
    required this.eventDates,
    required this.onUseExistingLocationChanged,
    required this.onSelectedLocationChanged,
    required this.onCustomLocationNameChanged,
    required this.onSelectMapLocation,
    required this.onSameLocationForAllDatesChanged,
    this.onValidationChanged,
  });

  @override
  State<LocationSelection> createState() => LocationSelectionState();
}

class LocationSelectionState extends State<LocationSelection> {
  bool _useSameLocationForAllDates = true;

  // Create GlobalKeys for each LocationSelector to access their states
  final Map<String, GlobalKey<LocationSelectorState>> _selectorKeys = {};

  // Add a validation state field
  bool _isCurrentlyValid = false;

  @override
  void initState() {
    super.initState();
    _initSelectorKeys();

    // Do initial validation after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _validateAndNotify();
    });
  }

  @override
  void didUpdateWidget(LocationSelection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.eventDates != oldWidget.eventDates) {
      // Preserve existing keys for dates that still exist
      final Map<String, GlobalKey<LocationSelectorState>> newKeys = {};
      for (var date in widget.eventDates) {
        // Keep existing key if date name already exists
        if (_selectorKeys.containsKey(date.name)) {
          newKeys[date.name] = _selectorKeys[date.name]!;
        } else {
          newKeys[date.name] = GlobalKey<LocationSelectorState>();
        }
      }
      setState(() {
        _selectorKeys.clear();
        _selectorKeys.addAll(newKeys);
      });
    }
  }

  void _initSelectorKeys() {
    _selectorKeys.clear();
    for (var eventDate in widget.eventDates) {
      _selectorKeys[eventDate.name] = GlobalKey<LocationSelectorState>();
    }
    // Add a fallback key for empty dates case
    if (_selectorKeys.isEmpty) {
      _selectorKeys['default'] = GlobalKey<LocationSelectorState>();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// Validates all locations based on the toggle state
  Map<String, dynamic> validateAllLocations() {
    debugPrint('🔍 [LocationSelection] Validating locations. Using same location for all dates: $_useSameLocationForAllDates');

    if (_useSameLocationForAllDates) {
      // Only need to validate the first location
      GlobalKey<LocationSelectorState>? firstKey = _selectorKeys.values.isNotEmpty ? _selectorKeys.values.first : null;

      if (firstKey?.currentState == null) {
        debugPrint('❌ [LocationSelection] First location state is null');
        return {'isValid': false, 'message': 'No se pudo validar la ubicación'};
      }

      final validation = firstKey!.currentState!.validateLocationData();
      debugPrint('📍 [LocationSelection] First location validation result: $validation');
      return validation;
    } else {
      // Need to validate all locations
      bool allValid = true;
      String? firstErrorMessage;

      debugPrint('🔄 [LocationSelection] Validating ${_selectorKeys.length} locations');

      for (var entry in _selectorKeys.entries) {
        if (entry.value.currentState == null) {
          debugPrint('⚠️ [LocationSelection] State is null for location: ${entry.key}');
          continue;
        }

        final validation = entry.value.currentState!.validateLocationData();
        debugPrint('📍 [LocationSelection] Location "${entry.key}" validation result: $validation');

        if (validation['isValid'] == false) {
          allValid = false;
          firstErrorMessage ??= 'Error en fecha "${entry.key}": ${validation['message']}';
        }
      }

      final result = {
        'isValid': allValid,
        'message': allValid ? null : (firstErrorMessage ?? 'Todas las ubicaciones deben ser válidas'),
      };
      debugPrint('✅ [LocationSelection] Final validation result: $result');
      return result;
    }
  }

  // Get the first location selector (used when same location for all dates)
  LocationSelectorState? getFirstSelector() {
    if (_selectorKeys.isEmpty) return null;

    final firstKey = _selectorKeys.values.first;
    return firstKey.currentState;
  }

  // Get all selectors by date name
  Map<String, LocationSelectorState?> getAllSelectors() {
    final result = <String, LocationSelectorState?>{};

    for (var entry in _selectorKeys.entries) {
      result[entry.key] = entry.value.currentState;
    }

    return result;
  }

  // Add this method to handle validation and notification
  void _validateAndNotify() {
    final validation = validateAllLocations();
    final isValid = validation['isValid'] as bool;

    if (isValid != _isCurrentlyValid) {
      _isCurrentlyValid = isValid;
      if (widget.onValidationChanged != null) {
        // Use Future.microtask to avoid rebuilding during build phase
        Future.microtask(() => widget.onValidationChanged!(isValid));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LivitBar(
            shadowType: ShadowType.weak,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LivitText(
                  'Ubicación',
                  textType: LivitTextType.smallTitle,
                ),
              ],
            ),
          ),
          _buildLocationSelector(),
          LivitSpaces.m,
          Padding(
            padding: LivitContainerStyle.padding(padding: [0, null, null, null]),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: LivitText(
                    'Usar la misma ubicación para todas las fechas',
                    textAlign: TextAlign.start,
                  ),
                ),
                ToggleButton(
                  initialValue: _useSameLocationForAllDates,
                  onToggle: (value) {
                    setState(() {
                      _useSameLocationForAllDates = value;
                    });
                    widget.onSameLocationForAllDatesChanged(value);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSelector() {
    if (widget.eventDates.isEmpty) {
      return Padding(
        padding: LivitContainerStyle.padding(padding: [null, null, 0, null]),
        child: LivitBar(
          shadowType: ShadowType.weak,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.exclamationmark_circle,
                color: LivitColors.whiteActive,
                size: LivitButtonStyle.iconSize,
              ),
              LivitSpaces.xs,
              LivitText('Agrega primero una fecha'),
            ],
          ),
        ),
      );
    }
    if (_useSameLocationForAllDates) {
      String keyName = widget.eventDates.isNotEmpty ? widget.eventDates.first.name : 'default';
      return LocationSelector(
        key: _selectorKeys[keyName],
        eventDate: widget.eventDates.first,
        onDataChanged: _validateAndNotify,
      );
    }

    return Column(
      children: widget.eventDates
          .map((eventDate) => Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LocationSelector(
                      key: _selectorKeys[eventDate.name],
                      eventDate: eventDate,
                      onDataChanged: _validateAndNotify,
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}
