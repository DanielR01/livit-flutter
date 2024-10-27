import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/enums.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/services/cloud/bloc/users/user_bloc.dart';
import 'package:livit/services/cloud/bloc/users/user_event.dart';
import 'package:livit/utilities/buttons/button.dart';
import 'package:livit/utilities/bars_containers_fields/glass_container.dart';
import 'package:livit/utilities/bars_containers_fields/title_bar.dart';

class UserTypeInput extends StatefulWidget {
  const UserTypeInput({super.key});

  @override
  State<UserTypeInput> createState() => _UserTypeInputState();
}

class _UserTypeInputState extends State<UserTypeInput> {
  UserType? _selectedUserType;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: LivitContainerStyle.paddingFromScreen,
          child: GlassContainer(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const TitleBar(
                  title: 'Elige tu tipo de usuario',
                  isBackEnabled: false,
                ),
                Padding(
                  padding: LivitContainerStyle.padding(padding: [0, null, null, null]),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const LivitText(
                        'Por alguna razon no se pudo obtener tu tipo de usuario. Selecciona si eres un consumidor (podrias ver eventos y comprar entradas) o un promotor (podrias crear eventos y gestionar entradas).',
                      ),
                      LivitSpaces.m,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: DropdownButton<UserType>(
                              isExpanded: true,
                              hint: const LivitText('Tipo de usuario'),
                              icon: Icon(
                                CupertinoIcons.chevron_down,
                                size: 16.sp,
                                color: LivitColors.whiteActive,
                              ),
                              style: LivitTextStyle.regularWhiteActiveBoldText,
                              borderRadius: LivitContainerStyle.borderRadius,
                              dropdownColor: LivitColors.mainBlack,
                              value: _selectedUserType,
                              onChanged: (UserType? newValue) {
                                setState(() {
                                  _selectedUserType = newValue!;
                                });
                              },
                              items: UserType.values.map((UserType userType) {
                                String text = userType.toString().split('.').last;
                                if (text == 'customer') {
                                  text = '- Consumidor';
                                } else if (text == 'promoter') {
                                  text = '- Promotor';
                                }
                                return DropdownMenuItem<UserType>(
                                  value: userType,
                                  child: LivitText(
                                    text,
                                    textAlign: TextAlign.left,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          LivitSpaces.m,
                          Button.main(
                            text: 'Continuar',
                            isActive: _selectedUserType != null,
                            onPressed: () => BlocProvider.of<UserBloc>(context).add(
                              SetUserType(userType: _selectedUserType!),
                            ),
                          ),
                        ],
                      ),
                    ],
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
