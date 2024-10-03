import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livit/services/cloud/bloc/events/events_bloc.dart';
import 'package:livit/services/cloud/bloc/events/events_event.dart';
import 'package:livit/services/cloud/bloc/events/events_state.dart';
import 'package:livit/services/cloud/firebase_cloud_storage.dart';
import 'package:livit/services/cloud/livit_event.dart';

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
    _eventsBloc = EventsBloc(
      storage: FirebaseCloudStorage(),
      creatorId: widget.creatorId,
    )..add(FetchInitialEvents());

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && _eventsBloc.state is! EventsLoading) {
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
        if (state is EventsLoading && state is! EventsLoaded) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is EventsLoaded) {
          if (state.events.isEmpty) {
            return const Center(child: Text('No Events Found'));
          }
          return ListView.builder(
            controller: _scrollController,
            itemCount: state.hasMore ? state.events.length + 1 : state.events.length,
            itemBuilder: (context, index) {
              if (index >= state.events.length) {
                // Show loading indicator at the bottom
                return const Center(child: CircularProgressIndicator());
              }
              final LivitEvent event = state.events[index];
              return ListTile(
                title: Text(event.name),
                subtitle: Text(event.description),
                // Add more details as needed
              );
            },
          );
        } else if (state is EventsError) {
          return Center(child: Text('Error: ${state.message}'));
        }
        return const Center(child: Text('Unexpected State'));
      },
    );
  }
}
