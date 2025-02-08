import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livit/models/event/event.dart';
import 'package:livit/services/background/background_bloc.dart';
import 'package:livit/services/firestore_storage/bloc/event/event_bloc.dart';
import 'package:livit/services/firestore_storage/bloc/event/event_event.dart';
import 'package:livit/services/firestore_storage/bloc/event/event_state.dart';
import 'package:livit/services/firestore_storage/bloc/location/location_bloc.dart';
import 'package:livit/services/firestore_storage/firestore_storage/firestore_storage.dart';

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
      storageService: FirestoreStorageService(),
      locationBloc: BlocProvider.of<LocationBloc>(context),
      backgroundBloc: BlocProvider.of<BackgroundBloc>(context),
    )..add(FetchInitialEvents());

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

        return const Center(child: Text('Unexpected State'));
      },
    );
  }
}
