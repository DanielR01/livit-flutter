import 'package:flutter/material.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/utilities/buttons/button.dart';

class FinalWelcomeMessage extends StatefulWidget {
  final VoidCallback onPressed;
  const FinalWelcomeMessage({super.key, required this.onPressed});

  @override
  State<FinalWelcomeMessage> createState() => _FinalWelcomeMessageState();
}

class _FinalWelcomeMessageState extends State<FinalWelcomeMessage> with TickerProviderStateMixin {
  late AnimationController _titleAnimationController;
  late AnimationController _descriptionAnimationController;
  late AnimationController _secondDescriptionAnimationController;
  late AnimationController _buttonAnimationController;

  late Animation<double> _titleAnimation;
  late Animation<double> _descriptionAnimation;
  late Animation<double> _secondDescriptionAnimation;
  late Animation<double> _buttonAnimation;

  bool _animationsCompleted = false;

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
      const Duration(milliseconds: 800),
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
                                _buttonAnimationController.forward().then((_) {
                                  setState(() {
                                    _animationsCompleted = true;
                                  });
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
          },
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _titleAnimationController.dispose();
    _descriptionAnimationController.dispose();
    _secondDescriptionAnimationController.dispose();
    _buttonAnimationController.dispose();
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
                  '¡Todo listo!',
                  textType: LivitTextType.bigTitle,
                ),
              ),
              LivitSpaces.s,
              FadeTransition(
                opacity: _descriptionAnimation,
                child: const LivitText('Disfruta de una nueva experiencia en LIVIT. Estamos trabajando para mejorar constantemente.'),
              ),
              LivitSpaces.s,
              FadeTransition(
                opacity: _secondDescriptionAnimation,
                child: const LivitText(
                    'Actualmente puedes comprar entradas para tus discotecas favoritas. Pronto podrás descubrir nuevos lugares y eventos que te encantarán.',
                    fontWeight: FontWeight.bold),
              ),
              LivitSpaces.m,
              FadeTransition(
                opacity: _buttonAnimation,
                child: Button.main(
                  text: 'Comenzar a usar LIVIT',
                  isActive: _animationsCompleted,
                  onPressed: widget.onPressed,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
