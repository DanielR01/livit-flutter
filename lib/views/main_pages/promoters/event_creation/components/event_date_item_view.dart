import 'package:flutter/material.dart';
import 'package:livit/views/main_pages/promoters/event_creation/components/event_date_item.dart';

class EventDateItemView extends StatelessWidget {
  final EventDateItem dateItem;

  const EventDateItemView({
    super.key,
    required this.dateItem,
  });

  @override
  Widget build(BuildContext context) {
    return dateItem.build(context);
  }
}
