import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/services/auth/bloc/auth_bloc.dart';
import 'package:livit/services/auth/bloc/auth_event.dart';
import 'package:livit/utilities/buttons/button.dart';

class MainViewScanner extends StatefulWidget {
  const MainViewScanner({super.key});

  @override
  State<MainViewScanner> createState() => _MainViewScannerState();
}

class _MainViewScannerState extends State<MainViewScanner> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            LivitText(
              'Scanner',
              textType: LivitTextType.normalTitle,
            ),
            LivitSpaces.xs,
            Button.main(
              text: 'Cerrar sesión',
              isActive: true,
              onTap: () {
                context.read<AuthBloc>().add( AuthEventLogOut(context));
              },
            ),
          ],
        ),
      ),
    );
  }
}
