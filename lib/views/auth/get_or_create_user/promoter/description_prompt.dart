import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/services/firestore_storage/bloc/user/user_bloc.dart';
import 'package:livit/services/firestore_storage/bloc/user/user_event.dart';
import 'package:livit/services/firestore_storage/bloc/user/user_state.dart';
import 'package:livit/utilities/bars_containers_fields/glass_container.dart';
import 'package:livit/utilities/bars_containers_fields/keyboard_dismissible.dart';
import 'package:livit/utilities/bars_containers_fields/livit_text_field.dart';
import 'package:livit/utilities/bars_containers_fields/title_bar.dart';
import 'package:livit/utilities/buttons/button.dart';

class DescriptionPrompt extends StatefulWidget {
  const DescriptionPrompt({super.key});

  @override
  State<DescriptionPrompt> createState() => _DescriptionPromptState();
}

class _DescriptionPromptState extends State<DescriptionPrompt> {
  late final TextEditingController _descriptionController;
  bool _isContinuable = false;

  bool _isContinueLoading = false;
  bool _isSkipLoading = false;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
    _descriptionController.addListener(_updateContinuableState);
  }

  @override
  void dispose() {
    _descriptionController.removeListener(_updateContinuableState);
    _descriptionController.dispose();
    super.dispose();
  }

  void _updateContinuableState() {
    setState(() {
      _isContinuable = _descriptionController.text.isNotEmpty && _descriptionController.text.length <= 100;
    });
  }

  Widget _buildBottomCaptionCharCount() {
    int charCount = _descriptionController.text.length;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LivitSpaces.s,
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            LivitText('$charCount/100 caracteres', textType: LivitTextType.regular, color: LivitColors.whiteInactive),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is CurrentUser && state.isLoading) {
          if (_descriptionController.text.isNotEmpty) {
            _isContinueLoading = true;
            _isSkipLoading = false;
          } else {
            _isContinueLoading = false;
            _isSkipLoading = true;
          }
        } else {
          _isContinueLoading = false;
          _isSkipLoading = false;
        }

        return KeyboardDismissible(
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.transparent,
            body: Center(
              child: Padding(
                padding: LivitContainerStyle.paddingFromScreen,
                child: GlassContainer(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const TitleBar(title: '¿Quien eres?'),
                      Padding(
                        padding: LivitContainerStyle.padding(padding: [0, null, null, null]),
                        child: Column(
                          children: [
                            const LivitText(
                              'Describe quien eres, mas adelante podras describir tu lugar o evento.',
                            ),
                            LivitSpaces.m,
                            LivitTextField(
                              controller: _descriptionController,
                              hint: 'Escribe aquí...',
                              isMultiline: true,
                              lines: 3,
                              bottomCaptionWidget: _buildBottomCaptionCharCount(),
                              regExp: RegExp(r'^.{1,100}$'),
                              disableCheckValidity: true,
                            ),
                            LivitSpaces.m,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Button.grayText(
                                  text: _isSkipLoading ? 'Continuando' : 'Completar más tarde',
                                  onTap: () {
                                    BlocProvider.of<UserBloc>(context).add(SetPromoterUserDescription(context, description: ''));
                                  },
                                  isActive: true,
                                  isLoading: _isSkipLoading,
                                  rightIcon: Icons.arrow_forward_ios,
                                ),
                                Button.main(
                                  text: _isContinueLoading ? 'Continuando' : 'Continuar',
                                  onTap: () {
                                    BlocProvider.of<UserBloc>(context)
                                        .add(SetPromoterUserDescription(context, description: _descriptionController.text));
                                  },
                                  isActive: _isContinuable,
                                  isLoading: _isContinueLoading,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
