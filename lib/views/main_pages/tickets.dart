import 'package:flutter/cupertino.dart';

class TicketsView extends StatefulWidget {
  
  const TicketsView({
    super.key,
    
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
