import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livit/constants/enums.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/services/background/background_bloc.dart';
import 'package:livit/services/background/background_events.dart';
import 'package:livit/services/background/background_states.dart';
import 'package:livit/services/firestore_storage/bloc/users/user_bloc.dart';
import 'package:livit/services/firestore_storage/bloc/users/user_event.dart';
import 'package:livit/services/firestore_storage/bloc/users/user_state.dart';
import 'package:livit/services/firestore_storage/firestore_storage/exceptions/firestore_exceptions.dart';
import 'package:livit/utilities/bars_containers_fields/glass_container.dart';
import 'package:livit/utilities/buttons/button.dart';
import 'package:livit/utilities/error_screens/error_reauth_screen.dart';

class WelcomeAndInterestsView extends StatefulWidget {
  const WelcomeAndInterestsView({super.key});

  @override
  State<WelcomeAndInterestsView> createState() => _WelcomeAndInterestsViewState();
}

class _WelcomeAndInterestsViewState extends State<WelcomeAndInterestsView> {
  bool _isShowingWelcome = true;

  void _onNext() {
    debugPrint('🔄 [WelcomeAndInterestsView] Stopping animation');
    BlocProvider.of<BackgroundBloc>(context, listen: false).add(BackgroundUnlockSpeed());
    BlocProvider.of<BackgroundBloc>(context, listen: false).add(BackgroundStopTransitionAnimation());
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
            return const _InterestsView();
          }
        } else {
          return ErrorReauthScreen(exception: UserInformationCorruptedException(details: 'No current user on WelcomeAndInterestsView'));
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
  late AnimationController _buttonAnimationController;

  late Animation<double> _titleAnimation;
  late Animation<double> _descriptionAnimation;
  late Animation<double> _buttonAnimation;

  bool _isAnimationFinished = false;

  @override
  void initState() {
    super.initState();
    debugPrint('🔄 [WelcomeAndInterestsView] Starting animation');
    BlocProvider.of<BackgroundBloc>(context, listen: false).add(BackgroundLockSpeed(AnimationSpeed.normal, 0.05));
    _titleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _descriptionAnimationController = AnimationController(
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
                        _buttonAnimationController.forward();
                        setState(() {
                          _isAnimationFinished = true;
                        });
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

  String get _welcomeDescription {
    switch (widget.userType) {
      case UserType.customer:
        return 'Con LIVIT podrás encontrar nuevos eventos y lugares en tu ciudad que se adapten a tus gustos.\nQueremos que compartas nuevas experiencias con tus amigos en tus eventos favoritos.';
      case UserType.promoter:
        return 'Con LIVIT podrás promocionar tus eventos y lugares de una manera más efectiva. Llegarás a más personas y podrás administrar tus eventos y entradas de manera fácil.';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      body: Center(
        child: Padding(
          padding: LivitContainerStyle.paddingFromScreen,
          child: Padding(
            padding: LivitContainerStyle.padding(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                FadeTransition(
                  opacity: _titleAnimation,
                  child: LivitText(
                    'Hola ${widget.name}',
                    textType: LivitTextType.bigTitle,
                  ),
                ),
                LivitSpaces.s,
                FadeTransition(
                  opacity: _descriptionAnimation,
                  child: LivitText(
                    _welcomeDescription,
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
      ),
    );
  }
}

class _InterestsView extends StatefulWidget {
  const _InterestsView();

  @override
  State<_InterestsView> createState() => _InterestsViewState();
}

class _InterestsViewState extends State<_InterestsView> {
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
        String title = '';
        String description = '';
        if (state is CurrentUser) {
          title = state.user.userType == UserType.customer ? 'Personaliza tus preferencias' : 'Personaliza tu perfil';
          description = state.user.userType == UserType.customer
              ? 'Escoge los temas que más te interesan para que podamos recomendarte nuevos eventos y lugares.'
              : 'Escoge los temas que más se relacionen con tu negocio para que tus clientes puedan encontrarte fácilmente.';
          _isLoading = state.isLoading;
        } else {
          return ErrorReauthScreen(exception: UserInformationCorruptedException(details: 'No current user on WelcomeAndInterestsView'));
        }
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Padding(
              padding: LivitContainerStyle.paddingFromScreen,
              child: GlassContainer(
                titleBarText: title,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                          SetUserInterests(context, interests: selectedTopics.toList()),
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
