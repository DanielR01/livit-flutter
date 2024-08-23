import 'package:flutter/cupertino.dart';
import 'package:livit/services/crud/tables/users/user.dart';

class TicketsView extends StatefulWidget {
  final LivitUser? user;
  const TicketsView({
    super.key,
    required this.user,
  });

  @override
  State<TicketsView> createState() => _TicketsViewState();
}

class _TicketsViewState extends State<TicketsView> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Tickets view'),
    );
  }
}
