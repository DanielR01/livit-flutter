import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:livit/services/firestore_storage/livit_ticket.dart';
import 'package:livit/services/firestore_storage/firestore_storage/collections.dart';
import 'package:livit/services/firestore_storage/firestore_storage/exceptions/firestore_exceptions.dart';

class TicketMethods {
  static final TicketMethods _shared = TicketMethods._sharedInstance();
  TicketMethods._sharedInstance();
  factory TicketMethods() => _shared;

  final Collections _collections = Collections();

  Stream<Iterable<LivitTicket>> getTicketsStream({required String userId}) {
    return _collections.ticketsCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()));
  }

  Future<Iterable<LivitTicket>> getTickets({required String userId}) async {
    try {
      final querySnapshot = await _collections.ticketsCollection
          .where('userId', isEqualTo: userId)
          .get();
      return querySnapshot.docs.map((doc) => doc.data());
    } catch (_) {
      throw CouldNotGetAllTicketsException();
    }
  }

  Future<LivitTicket> createTicket({required LivitTicket ticket}) async {
    try {
      final docRef = await _collections.ticketsCollection.add(ticket);
      final doc = await docRef.get();
      return doc.data()!;
    } catch (_) {
      throw CouldNotCreateTicketException();
    }
  }

  Future<void> updateTicket({required LivitTicket ticket}) async {
    try {
      await _collections.ticketsCollection
          .doc(ticket.ticketId)
          .update(ticket.toMap());
    } catch (_) {
      throw CouldNotUpdateTicketException();
    }
  }

  Future<void> deleteTicket({required String ticketId}) async {
    try {
      await _collections.ticketsCollection.doc(ticketId).delete();
    } catch (_) {
      throw CouldNotDeleteTicketException();
    }
  }

  Future<List<LivitTicket>> getTicketsPaginated({
    required String userId,
    required int limit,
    DocumentSnapshot<LivitTicket>? startAfterDoc,
  }) async {
    try {
      Query<LivitTicket> query = _collections.ticketsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('ticketTypeName')
          .limit(limit);

      if (startAfterDoc != null) {
        query = query.startAfterDocument(startAfterDoc);
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (_) {
      throw CouldNotGetAllTicketsException();
    }
  }
} 