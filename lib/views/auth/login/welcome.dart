import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:livit/constants/routes.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/constants/enums.dart';
import 'package:livit/services/error_reporting/error_reporter.dart';
import 'package:livit/utilities/buttons/button.dart';

class WelcomeView extends StatefulWidget {
  const WelcomeView({super.key});

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> {
  bool displayContent = false;
  bool displayLivit = false;
  bool animationsCompleted = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(1.seconds, () {
      if (mounted) {
        setState(() {
          displayLivit = true;
        });
      }
    });
    Future.delayed(4.seconds, () {
      if (mounted) {
        setState(() {
          displayContent = true;
        });
      }
    });
    Future.delayed(4.seconds, () {
      if (mounted) {
        setState(() {
          animationsCompleted = true;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();

    debugPrint('🔄 [WelcomeView] Disposing WelcomeView');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (displayLivit)
              Animate(
                effects: [
                  FadeEffect(duration: 500.ms, curve: Curves.easeOut),
                ],
                child: const LivitText(
                  'LIVIT',
                  textType: LivitTextType.bigTitle,
                ),
              ),
            if (displayContent)
              Animate(
                effects: [
                  FadeEffect(duration: 500.ms, curve: Curves.easeOut),
                  SlideEffect(
                    begin: const Offset(0, 0.05),
                    end: Offset.zero,
                    duration: 500.ms,
                    curve: Curves.easeOut,
                  ),
                ],
                child: WelcomeMessage(animationsCompleted: animationsCompleted),
              ),
          ],
        ),
      ),
    );
  }
}

class WelcomeMessage extends StatelessWidget {
  final bool animationsCompleted;
  static final errorReporter = ErrorReporter(viewName: 'WelcomeMessage');

  const WelcomeMessage({super.key, required this.animationsCompleted});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.sp),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const LivitText('Encuentra más de lo que te gusta,'),
          const LivitText('más eventos, más lugares, más personas.'),
          LivitSpaces.m,
          Button.main(
            text: 'Comenzar',
            isActive: animationsCompleted,
            onTap: () async {
              Navigator.of(context).pushNamedAndRemoveUntil(
                Routes.authRoute,
                (route) => false,
                arguments: {'userType': UserType.customer},
              );
            },
          ),
        ],
      ),
    );
  }
}
