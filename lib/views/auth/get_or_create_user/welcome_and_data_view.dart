import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livit/constants/enums.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/services/cloud/bloc/users/user_bloc.dart';
import 'package:livit/services/cloud/bloc/users/user_event.dart';
import 'package:livit/services/cloud/bloc/users/user_state.dart';
import 'package:livit/utilities/buttons/button.dart';
import 'package:livit/utilities/error_screens/error_reauth_screen.dart';

class WelcomeAndDataView extends StatefulWidget {
  const WelcomeAndDataView({super.key});

  @override
  State<WelcomeAndDataView> createState() => _WelcomeAndDataViewState();
}

class _WelcomeAndDataViewState extends State<WelcomeAndDataView> {
  bool _isShowingWelcome = true;

  void _onNext() {
    setState(
      () {
        _isShowingWelcome = false;
      },
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is CurrentUser) {
          if (_isShowingWelcome) {
            return _WelcomeView(name: state.user.name, onNext: _onNext, userType: state.user.userType);
          } else {
            return const InterestsView();
          }
        } else {
          return const ErrorReauthScreen();
        }
      },
    );
  }
}

class _WelcomeView extends StatefulWidget {
  final String name;
  final VoidCallback onNext;
  final UserType userType;
  const _WelcomeView({required this.name, required this.onNext, required this.userType});

  @override
  State<_WelcomeView> createState() => __WelcomeViewState();
}

class __WelcomeViewState extends State<_WelcomeView> with TickerProviderStateMixin {
  late AnimationController _titleAnimationController;
  late AnimationController _descriptionAnimationController;
  late AnimationController _secondDescriptionAnimationController;
  late AnimationController _buttonAnimationController;

  late Animation<double> _titleAnimation;
  late Animation<double> _descriptionAnimation;
  late Animation<double> _secondDescriptionAnimation;
  late Animation<double> _buttonAnimation;

  bool _isAnimationFinished = false;

  @override
  void initState() {
    super.initState();

    _titleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _descriptionAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _secondDescriptionAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _buttonAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _titleAnimation = CurvedAnimation(
      parent: _titleAnimationController,
      curve: Curves.easeOut,
    );
    _descriptionAnimation = CurvedAnimation(
      parent: _descriptionAnimationController,
      curve: Curves.easeOut,
    );
    _secondDescriptionAnimation = CurvedAnimation(
      parent: _secondDescriptionAnimationController,
      curve: Curves.easeOut,
    );
    _buttonAnimation = CurvedAnimation(
      parent: _buttonAnimationController,
      curve: Curves.easeOut,
    );

    Future.delayed(
      const Duration(milliseconds: 1600),
    ).then(
      (_) {
        _titleAnimationController.forward().then(
          (_) {
            Future.delayed(const Duration(milliseconds: 1600)).then(
              (_) {
                _descriptionAnimationController.forward().then(
                  (_) {
                    Future.delayed(const Duration(milliseconds: 1600)).then(
                      (_) {
                        _secondDescriptionAnimationController.forward().then(
                          (_) {
                            Future.delayed(const Duration(milliseconds: 1600)).then(
                              (_) {
                                _buttonAnimationController.forward();
                                setState(
                                  () {
                                    _isAnimationFinished = true;
                                  },
                                );
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _titleAnimationController.dispose();
    _descriptionAnimationController.dispose();
    _buttonAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Padding(
          padding: LivitContainerStyle.paddingFromScreen,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              FadeTransition(
                opacity: _titleAnimation,
                child: LivitText(
                  'Hola ${widget.name}',
                  textType: TextType.bigTitle,
                ),
              ),
              LivitSpaces.s,
              FadeTransition(
                opacity: _descriptionAnimation,
                child: LivitText(
                  'Con LIVIT podras encontrar nuevos eventos y lugares en tu ciudad que se adapten a tus gustos. Queremos que compartas nuevas experiencias con tus amigos y conozcas nuevas personas.',
                ),
              ),
              LivitSpaces.s,
              FadeTransition(
                opacity: _secondDescriptionAnimation,
                child: LivitText(
                  'Estás usando una versión inicial de LIVIT, por el momento solo podrás comprar entradas para tus eventos favoritos.',
                  fontWeight: FontWeight.bold,
                ),
              ),
              LivitSpaces.m,
              FadeTransition(
                opacity: _buttonAnimation,
                child: Button.main(
                  text: 'Continuar',
                  isActive: _isAnimationFinished,
                  onPressed: widget.onNext,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InterestsView extends StatefulWidget {
  const InterestsView({super.key});

  @override
  State<InterestsView> createState() => _InterestsViewState();
}

class _InterestsViewState extends State<InterestsView> {
  final List<String> topics = [
    'Rumba',
    'Espiritualidad',
    'Deportes',
    'Fotografía',
    'Gaming',
    'Comida',
    'Autos',
    'Teatro',
    'Alta Cocina',
    'Mascotas',
    'Cocteles',
    'Cafe',
    'Cerveza',
    'Arte',
    'Festivales',
    'Moda',
    'Música',
  ];

  final Set<String> selectedTopics = {};

  void _toggleTopic(String topic) {
    setState(() {
      if (selectedTopics.contains(topic)) {
        selectedTopics.remove(topic);
      } else {
        selectedTopics.add(topic);
      }
    });
  }

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        String title = 'Personaliza tus preferencias';
        String description = 'Escoge los temas que más te interesan para que podamos recomendarte nuevos eventos y lugares.';
        if (state is CurrentUser) {
          _isLoading = state.isLoading;
        }
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Padding(
              padding: LivitContainerStyle.paddingFromScreen,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LivitText(
                      title,
                      textType: TextType.bigTitle,
                    ),
                    LivitSpaces.m,
                    LivitText(
                      description,
                      textAlign: TextAlign.center,
                    ),
                    LivitSpaces.l,
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
                      children: topics.map((topic) {
                        return Button.secondary(
                          text: topic,
                          isActive: selectedTopics.contains(topic),
                          onPressed: () => _toggleTopic(topic),
                          forceOnPressed: true,
                        );
                      }).toList(),
                    ),
                    LivitSpaces.l,
                    Button.main(
                      text: _isLoading ? 'Continuando' : 'Continuar',
                      isActive: selectedTopics.isNotEmpty,
                      isLoading: _isLoading,
                      onPressed: () {
                        BlocProvider.of<UserBloc>(context).add(
                          SetUserInterests(interests: selectedTopics.toList()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
