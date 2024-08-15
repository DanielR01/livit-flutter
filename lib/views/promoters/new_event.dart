import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/styles/bar_style.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/constants/styles/text_style.dart';
import 'package:livit/services/crud/livit_db_service.dart';
import 'package:livit/services/crud/tables/events/event.dart';
import 'package:livit/utilities/background/main_background.dart';
import 'package:livit/utilities/bars_containers_fields/bar.dart';
import 'package:livit/utilities/bars_containers_fields/glass_container.dart';
import 'package:livit/utilities/buttons/arrow_back_button.dart';
import 'package:livit/utilities/buttons/action_button.dart';

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

  Future<LivitEvent?> createNewEvent() async {
    final existingEvent = _event;
    if (existingEvent != null) {
      return existingEvent;
    }
    return null;
  }

  @override
  void initState() {
    _titleController = TextEditingController();
    _dateController = TextEditingController();
    _descriptionController = TextEditingController();
    _locationController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const MainBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 10,
                right: 10,
              ),
              child: Column(
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                ),
                                width: double.infinity,
                                child: TextField(
                                  controller: _titleController,
                                  textAlign: TextAlign.center,
                                  maxLines: 3,
                                  minLines: 1,
                                  decoration: InputDecoration(
                                    hintText: 'Titulo del evento',
                                    hintStyle:
                                        LivitTextStyle.regularWhiteActiveText,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                width: double.infinity,
                                child: TextField(
                                  controller: _dateController,
                                  textAlign: TextAlign.center,
                                  maxLines: 3,
                                  minLines: 1,
                                  decoration: InputDecoration(
                                    hintText: 'Fecha del evento',
                                    hintStyle:
                                        LivitTextStyle.regularWhiteActiveText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Positioned(
                            top: 0,
                            left: 16,
                            child: SizedBox(
                              height: 54,
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          width: double.infinity,
                          child: TextField(
                            controller: _descriptionController,
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            minLines: 1,
                            decoration: InputDecoration(
                              hintText: 'Descripción',
                              hintStyle: LivitTextStyle.regularWhiteActiveText,
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          width: double.infinity,
                          child: TextField(
                            controller: _locationController,
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            minLines: 1,
                            decoration: InputDecoration(
                              hintText: 'Localización',
                              hintStyle: LivitTextStyle.regularWhiteActiveText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  LivitSpaces.mediumPlus24spacer,
                  MainActionButton(
                    
                    text: 'Crear evento',
                    isActive: true,
                    onPressed: () {},
                  )
                ],
              ),
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
        size: 14,
      ),
    );
  }
}
