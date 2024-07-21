import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/constants/styles/text_style.dart';
import 'package:livit/utilities/bars_containers_fields/bar.dart';
import 'package:livit/utilities/buttons/arrow_back_button.dart';
import 'package:livit/utilities/buttons/main_action_button.dart';
import 'package:livit/utilities/bars_containers_fields/text_field.dart';

class CreateAccountView extends StatefulWidget {
  final ValueChanged<int> goBackCallback;
  const CreateAccountView({
    super.key,
    required this.goBackCallback,
  });

  @override
  State<CreateAccountView> createState() => _CreateAccountViewState();
}

class _CreateAccountViewState extends State<CreateAccountView> {
  late final TextEditingController phoneNumberController;

  @override
  void initState() {
    phoneNumberController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
          ),
          child: Container(
            decoration: LivitContainerStyle.decoration,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Bar(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        left: 0,
                        child: ArrowBackButton(
                          onPressed: () {
                            widget.goBackCallback(1);
                          },
                        ),
                      ),
                      Text(
                        'Crear tu cuenta',
                        style: LivitTextStyle(
                          textColor: LivitColors.whiteActive,
                        ).normalTitleTextStyle,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: LivitContainerStyle.padding,
                  child: Column(
                    children: [
                      Text(
                        textAlign: TextAlign.center,
                        'Para mantener seguros tus tickets, es necesario que uses tu numero de teléfono al crear tu cuenta.',
                        style:
                            LivitTextStyle(textColor: LivitColors.whiteActive)
                                .regularTextStyle,
                      ),
                      LivitSpaces.medium16spacer,
                      LivitTextField(
                        controller: phoneNumberController,
                        hint: 'Numero de teléfono',
                        inputType: TextInputType.number,
                        phoneNumberField: true,
                        regExp: RegExp(r'^\d{4,15}$'),
                        onChanged: (value) {},
                      ),
                      LivitSpaces.medium16spacer,
                      MainActionButton(
                        text: 'Continuar',
                        isActive: false,
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
