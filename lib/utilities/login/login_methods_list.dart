import 'package:flutter/material.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/constants/enums.dart';
import 'package:livit/utilities/bars_containers_fields/glass_container.dart';
import 'package:livit/utilities/bars_containers_fields/title_bar.dart';
import 'package:livit/utilities/buttons/login_buttons/email_login_bar.dart';
import 'package:livit/utilities/buttons/login_buttons/phone_login_bar.dart';
import 'package:livit/utilities/buttons/login_buttons/promoter_login_bar.dart';
import 'package:livit/utilities/buttons/login_buttons/apple_login_bar.dart';
import 'package:livit/utilities/buttons/login_buttons/google_login_bar.dart';

class LoginMethodsList extends StatefulWidget {
  final UserType userType;

  const LoginMethodsList({
    super.key,
    required this.userType,
  });

  @override
  State<LoginMethodsList> createState() => _LoginMethodsListState();
}

class _LoginMethodsListState extends State<LoginMethodsList> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              GlassContainer(
                child: Column(
                  children: [
                    TitleBar(
                      title: widget.userType == UserType.customer ? 'Ingresa a Livit' : 'Ingresa como Promocionador',
                      isBackEnabled: widget.userType == UserType.promoter,
                    ),
                    Padding(
                      padding: LivitContainerStyle.padding(padding: [0, null, null, null]),
                      child: Column(
                        children: [
                          widget.userType == UserType.promoter
                              ? Column(
                                  children: [
                                    const LivitText(
                                      'En LIVIT podras promocionar tus eventos y negocio, permitiendo que muchos mas clientes te encuentren y tengan una gran experiencia de compra.',
                                    ),
                                    LivitSpaces.m,
                                  ],
                                )
                              : const SizedBox(),
                          EmailLoginBar(
                            userType: widget.userType,
                          ),
                          LivitSpaces.m,
                          PhoneLoginBar(
                            userType: widget.userType,
                          ),
                          LivitSpaces.m,
                          const Divider(
                            height: 1,
                            color: LivitColors.whiteInactive,
                          ),
                          LivitSpaces.m,
                          const LivitText(
                            'O también puedes',
                          ),
                          LivitSpaces.m,
                          const AppleLoginBar(),
                          LivitSpaces.m,
                          GoogleLoginBar(
                            userType: widget.userType,
                          ),
                          LivitSpaces.m,
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              LivitSpaces.l,
              widget.userType == UserType.customer
                  ? GlassContainer(
                      child: Padding(
                        padding: LivitContainerStyle.padding(),
                        child: Column(
                          children: [
                            const LivitText(
                              'Estas interesado en promocionar tus eventos?',
                            ),
                            LivitSpaces.m,
                            PromoterLoginBar(),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox(),
            ],
          ),
        ),
      ],
    );
  }
}
