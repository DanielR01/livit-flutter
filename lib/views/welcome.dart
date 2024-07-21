import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/constants/styles/text_style.dart';
import 'package:livit/utilities/buttons/main_action_button.dart';

class WelcomeView extends StatefulWidget {
  final ValueChanged<int> goToSignIn;
  const WelcomeView({
    super.key,
    required this.goToSignIn,
  });

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> {
  bool displayText = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height,
      width: MediaQuery.sizeOf(context).width,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Livit',
              style: LivitTextStyle(
                textColor: LivitColors.whiteActive,
              ).bigTitleTextStyle,
            )
                .animate()
                .fade(delay: 1600.ms, duration: 300.ms, curve: Curves.easeOut)
                .slideY(begin: 0.2, end: 0, curve: Curves.easeOut)
                .callback(
                  delay: 3600.ms,
                  callback: (_) {
                    setState(
                      () {
                        displayText = true;
                      },
                    );
                  },
                ),
            displayText
                ? WelcomeMessage(
                    signInCallback: widget.goToSignIn,
                  )
                    .animate()
                    .fade(duration: 300.ms, curve: Curves.easeOut)
                    .slideY(begin: 0.2, end: 0, curve: Curves.easeOut)
                : const SizedBox()
          ],
        ),
      ),
    );
  }
}

class WelcomeMessage extends StatelessWidget {
  final ValueChanged<int> signInCallback;
  const WelcomeMessage({
    super.key,
    required this.signInCallback,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Encuentra mas de lo que te gusta,',
          style: LivitTextStyle(
            textColor: LivitColors.whiteActive,
          ).regularTextStyle,
        ),
        Text(
          'mas eventos, mas lugares, mas personas.',
          style: LivitTextStyle(
            textColor: LivitColors.whiteActive,
          ).regularTextStyle,
        ),
        LivitSpaces.mediumPlus24spacer,
        MainActionButton(
          text: 'Iniciar sesión',
          isActive: true,
          onPressed: () => signInCallback(1),
        ),
      ],
    );
  }
}
