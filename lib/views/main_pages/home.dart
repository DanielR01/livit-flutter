import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livit/models/event/event.dart';
import 'package:livit/services/background/background_bloc.dart';
import 'package:livit/services/firestore_storage/bloc/event/event_bloc.dart';
import 'package:livit/services/firestore_storage/bloc/event/event_event.dart';
import 'package:livit/services/firestore_storage/bloc/event/event_state.dart';
import 'package:livit/services/firestore_storage/bloc/location/location_bloc.dart';
import 'package:livit/services/firestore_storage/firestore_storage/firestore_storage.dart';
import 'package:livit/services/cloud_functions/firestore_cloud_functions.dart';

class HomePage extends StatefulWidget {
  final String creatorId;
  const HomePage({
    super.key,
    required this.creatorId,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late EventsBloc _eventsBloc;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _eventsBloc = BlocProvider.of<EventsBloc>(context);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && _eventsBloc.state is! EventsLoaded) {
        _eventsBloc.add(FetchMoreEvents());
      }
    });
  }

  @override
  void dispose() {
    _eventsBloc.close();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventsBloc, EventsState>(
      bloc: _eventsBloc,
      builder: (context, state) {
        if (state is EventsInitial) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is EventsLoaded) {
          // Handle loaded events
          return const Center(child: Text('Events loaded - Implement UI'));
        } else if (state is EventsError) {
          return Center(child: Text('Error: ${state.message}'));
        } else if (state is EventCreating) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is EventCreated) {
          // Event was successfully created
          return Center(child: Text('Event created with ID: ${state.eventId}'));
        } else if (state is EventCreationError) {
          return Center(child: Text('Error creating event: ${state.message}'));
        }

        return const Center(child: Text('Unexpected State'));
      },
    );
  }
}
