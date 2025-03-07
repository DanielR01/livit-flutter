import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livit/services/auth/bloc/auth_bloc.dart';
import 'package:livit/services/auth/bloc/auth_event.dart';
import 'package:livit/utilities/buttons/button.dart';
import 'package:livit/utilities/display/livit_display_area.dart';

class PromoterProfile extends StatefulWidget {
  const PromoterProfile({super.key});

  @override
  State<PromoterProfile> createState() => _PromoterProfileState();
}

class _PromoterProfileState extends State<PromoterProfile> {
  @override
  Widget build(BuildContext context) {
    return LivitDisplayArea(
      child: Center(
        child: Button.main(
            text: 'Log out',
            isActive: true,
            onTap: () {
              BlocProvider.of<AuthBloc>(context).add(AuthEventLogOut(context));
            }),
      ),
    );
  }
}
