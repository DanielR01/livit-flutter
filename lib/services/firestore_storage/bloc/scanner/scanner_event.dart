part of 'scanner_bloc.dart';

abstract class ScannerEvent {}

class CreateScanner extends ScannerEvent {
  final String name;
  final String locationId;
  final String? eventId;

  CreateScanner({
    required this.locationId,
    required this.name,
    this.eventId,
  });
}

class UpdateScannerAccess extends ScannerEvent {
  final String scannerId;
  final List<String> addLocationIds;
  final List<String> removeLocationIds;
  final List<String> addEventIds;
  final List<String> removeEventIds;

  UpdateScannerAccess({
    required this.scannerId,
    required this.addLocationIds,
    required this.removeLocationIds,
    required this.addEventIds,
    required this.removeEventIds,
  });
}

class GetScannersByLocationId extends ScannerEvent {
  final String locationId;

  GetScannersByLocationId({required this.locationId});
}

