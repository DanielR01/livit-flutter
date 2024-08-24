import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/constants/styles/text_style.dart';
import 'package:livit/services/auth/auth_service.dart';
import 'package:livit/services/crud/livit_db_service.dart';
import 'package:livit/services/crud/tables/events/event.dart';
import 'package:livit/utilities/background/main_background.dart';
import 'package:livit/utilities/bars_containers_fields/glass_container.dart';
import 'package:livit/utilities/buttons/arrow_back_button.dart';
import 'package:livit/utilities/buttons/action_button.dart';
import 'package:livit/utilities/loading_screen.dart';

class NewEventView extends StatefulWidget {
  const NewEventView({super.key});

  @override
  State<NewEventView> createState() => _NewEventViewState();
}

class _NewEventViewState extends State<NewEventView> {
  late final TextEditingController _titleController;
  late final TextEditingController _dateController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _locationController;

  LivitEvent? _event;
  late final LivitDBService _livitDBService;

  void _textControllersListener() async {
    // TODO update this listener so that event update doesnt update everything
    _saveEventIfNotEmpty();
  }

  void _setupTextControllersListener() {
    // TODO change this according to the change in the controllers listeners
    _titleController.removeListener(_textControllersListener);
    _descriptionController.removeListener(_textControllersListener);
    _dateController.removeListener(_textControllersListener);
    _locationController.removeListener(_textControllersListener);

    _titleController.addListener(_textControllersListener);
    _descriptionController.addListener(_textControllersListener);
    _dateController.addListener(_textControllersListener);
    _locationController.addListener(_textControllersListener);
  }

  Future<LivitEvent> createNewEvent() async {
    final existingEvent = _event;
    if (existingEvent != null) {
      return existingEvent;
    }
    final currentUser = AuthService.firebase().currentUser;
    final user = await _livitDBService.getUserWithId(id: currentUser!.id!);
    final String title = _titleController.text;
    final String location = _locationController.text;
    final newEvent = await _livitDBService.createEvent(
      userCreator: user,
      title: title,
      location: location,
    );
    return newEvent;
  }

  Future<void> _deleteEventIfEmpty() async {
    final event = _event;
    if ((_titleController.text.isEmpty && _locationController.text.isEmpty) &&
        event != null) {
      await _livitDBService.deleteEvent(id: event.id);
    }
  }

  Future<void> _saveEventIfNotEmpty() async {
    final event = _event;
    final title = _titleController.text;
    final location = _locationController.text;
    if ((title.isNotEmpty || location.isNotEmpty) && event != null) {
      await _livitDBService.updateEvent(
        event: event,
        location: location,
        title: title,
      );
    }
  }

  @override
  void initState() {
    _titleController = TextEditingController();
    _dateController = TextEditingController();
    _descriptionController = TextEditingController();
    _locationController = TextEditingController();

    _livitDBService = LivitDBService();

    super.initState();
  }

  @override
  void dispose() async {
    _titleController.dispose();
    _dateController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();

    super.dispose();

    await _deleteEventIfEmpty();
    await _saveEventIfNotEmpty();
    _livitDBService.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const MainBackground(),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                left: 10.sp,
                right: 10.sp,
              ),
              child: FutureBuilder(
                  future: createNewEvent(),
                  builder: (context, snapshot) {
                    //print(
                    //    'data: ${snapshot.data}, state: ${snapshot.connectionState} ');
                    switch (snapshot.connectionState) {
                      case ConnectionState.done:
                        _event = snapshot.data;
                        _setupTextControllersListener();
                        return Column(
                          children: [
                            GlassContainer(
                              child: SizedBox(
                                width: double.infinity,
                                // decoration: LivitBarStyle.normalDecoration,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 32.sp,
                                          ),
                                          width: double.infinity,
                                          child: TextField(
                                            controller: _titleController,
                                            textAlign: TextAlign.center,
                                            maxLines: 3,
                                            minLines: 1,
                                            decoration: InputDecoration(
                                              hintText: 'Titulo del evento',
                                              hintStyle: LivitTextStyle
                                                  .regularWhiteActiveText,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 16.sp,
                                          ),
                                          width: double.infinity,
                                          child: TextField(
                                            controller: _dateController,
                                            textAlign: TextAlign.center,
                                            maxLines: 3,
                                            minLines: 1,
                                            decoration: InputDecoration(
                                              hintText: 'Fecha del evento',
                                              hintStyle: LivitTextStyle
                                                  .regularWhiteActiveText,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Positioned(
                                      top: 0,
                                      left: 16.sp,
                                      child: SizedBox(
                                        height: 54.sp,
                                        child: ArrowBackButton(
                                          onPressed: () {
                                            Navigator.of(context).maybePop();
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            LivitSpaces.medium16spacer,
                            GlassContainer(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16.sp,
                                    ),
                                    width: double.infinity,
                                    child: TextField(
                                      controller: _descriptionController,
                                      textAlign: TextAlign.center,
                                      maxLines: 3,
                                      minLines: 1,
                                      decoration: InputDecoration(
                                        hintText: 'Descripción',
                                        hintStyle: LivitTextStyle
                                            .regularWhiteActiveText,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            LivitSpaces.medium16spacer,
                            GlassContainer(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16.sp,
                                    ),
                                    width: double.infinity,
                                    child: TextField(
                                      controller: _locationController,
                                      textAlign: TextAlign.center,
                                      maxLines: 3,
                                      minLines: 1,
                                      decoration: InputDecoration(
                                        hintText: 'Localización',
                                        hintStyle: LivitTextStyle
                                            .regularWhiteActiveText,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            LivitSpaces.mediumPlus24spacer,
                            MainActionButton(
                              //width: double.infinity,
                              text: 'Crear evento',
                              isActive: true,
                              onPressed: () async {
                              },
                            )
                          ],
                        );
                      default:
                        return const LoadingScreen();
                    }
                  }),
            ),
          ),
        ],
      ),
    );
  }
}

class LivitBackButton extends StatelessWidget {
  const LivitBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        Navigator.of(context).maybePop();
      },
      icon: Icon(
        Icons.arrow_back_ios_new_rounded,
        size: 14.sp,
      ),
    );
  }
}
