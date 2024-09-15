import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:livit/constants/routes.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/constants/user_types.dart';
import 'package:livit/utilities/buttons/button.dart';

class WelcomeView extends StatefulWidget {
  const WelcomeView({super.key});

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> {
  bool displayContent = false;
  bool displayLivit = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(1.seconds, () {
      setState(() {
        displayLivit = true;
      });
    });
    Future.delayed(4.seconds, () {
      setState(() {
        displayContent = true;
      });
    });
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
                  textType: TextType.bigTitle,
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
                child: const WelcomeMessage(),
              ),
          ],
        ),
      ),
    );
  }
}

class WelcomeMessage extends StatelessWidget {
  const WelcomeMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.sp),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const LivitText('Encuentra mas de lo que te gusta,'),
          const LivitText('mas eventos, mas lugares, mas personas.'),
          LivitSpaces.m,
          Button.main(
            text: 'Comenzar',
            isActive: true,
            onPressed: () {
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
