import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:livit/models/user/cloud_user.dart';
import 'package:livit/models/user/private_data.dart';
import 'package:livit/services/firestore_storage/firestore_storage/collections.dart';
import 'package:livit/services/firestore_storage/firestore_storage/methods/location_service.dart';
import 'package:livit/services/firestore_storage/firestore_storage/methods/private_data_service.dart';
import 'package:livit/services/firestore_storage/firestore_storage/methods/product_sale_service.dart';
import 'package:livit/services/firestore_storage/firestore_storage/methods/product_service.dart';
import 'package:livit/services/firestore_storage/firestore_storage/methods/scanner_service.dart';
import 'package:livit/services/firestore_storage/firestore_storage/methods/ticket_service.dart';
import 'package:livit/services/firestore_storage/firestore_storage/methods/user_service.dart';
import 'package:livit/services/firestore_storage/firestore_storage/methods/event_service.dart';
import 'package:livit/services/firestore_storage/firestore_storage/methods/username_service.dart';
import 'package:livit/services/firestore_storage/firestore_storage/methods/location_schedule_service.dart';

class FirestoreStorageService {
  static final FirestoreStorageService _shared = FirestoreStorageService._sharedInstance();
  FirestoreStorageService._sharedInstance();
  factory FirestoreStorageService() => _shared;

  final UserService userService = UserService();
  final UsernameService usernameService = UsernameService();
  final EventService eventService = EventService();
  final TicketService ticketService = TicketService();
  final PrivateDataService privateDataService = PrivateDataService();
  final LocationService locationService = LocationService();
  final ProductService productService = ProductService();
  final ProductSaleService productSaleService = ProductSaleService();
  final LocationScheduleService locationScheduleService = LocationScheduleService();
  final ScannerService scannerService = ScannerService();
}
