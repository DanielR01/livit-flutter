import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:livit/constants/routes.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/constants/user_types.dart';
import 'package:livit/utilities/buttons/button.dart';

class WelcomeView extends StatefulWidget {
  const WelcomeView({
    super.key,
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
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const LivitText(
              'LIVIT',
              textType: TextType.bigTitle,
            )
                .animate()
                .fade(delay: 1600.ms, duration: 300.ms, curve: Curves.easeOut)
                .slideY(begin: 0.2.sp, end: 0, curve: Curves.easeOut)
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
                ? const WelcomeMessage()
                    .animate()
                    .fade(duration: 300.ms, curve: Curves.easeOut)
                    .slideY(begin: 0.2.sp, end: 0, curve: Curves.easeOut)
                : const SizedBox()
          ],
        ),
      ),
    );
  }
}

class WelcomeMessage extends StatelessWidget {
  const WelcomeMessage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 10.sp,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LivitSpaces.s,
          const LivitText(
            'Encuentra mas de lo que te gusta,',
          ),
          const LivitText(
            'mas eventos, mas lugares, mas personas.',
          ),
          LivitSpaces.l,
          Button.main(
            text: 'Comenzar',
            isActive: true,
            onPressed: () {
              Navigator.of(context).pushNamed(
                Routes.authRoute,
                arguments: {
                  'userType': UserType.customer,
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
