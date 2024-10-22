import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/enums.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/services/cloud/bloc/users/user_event.dart';
import 'package:livit/services/cloud/bloc/users/user_state.dart';
import 'package:livit/services/cloud/bloc/users/user_bloc.dart';
import 'package:livit/services/cloud/cloud_storage_exceptions.dart';
import 'package:livit/utilities/buttons/button.dart';
import 'package:livit/utilities/bars_containers_fields/glass_container.dart';
import 'package:livit/utilities/bars_containers_fields/title_bar.dart';
import 'package:livit/utilities/bars_containers_fields/text_field.dart';

class CreateUserView extends StatefulWidget {
  const CreateUserView({super.key});

  @override
  State<CreateUserView> createState() => _CreateUserViewState();
}

class _CreateUserViewState extends State<CreateUserView> with TickerProviderStateMixin {
  late AnimationController _titleController;
  late AnimationController _containerController;
  late Animation<double> _titleAnimation;
  late Animation<Offset> _containerAnimation;

  late final TextEditingController _usernameController;
  late final TextEditingController _nameController;

  bool _showContainer = false;

  bool _isNameValid = false;
  bool _isUsernameValid = false;

  bool _isLoading = false;
  late UserType _userType;

  String? _bottomCaptionText;

  @override
  void initState() {
    _usernameController = TextEditingController();
    _nameController = TextEditingController();
    super.initState();

    _titleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _containerController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _titleAnimation = CurvedAnimation(parent: _titleController, curve: Curves.easeIn);

    _containerAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _containerController,
      curve: Curves.easeOut,
    ));

    Future.delayed(const Duration(milliseconds: 1600)).then((_) {
      if (mounted) {
        _titleController.forward().then((_) {
          Future.delayed(const Duration(milliseconds: 1600)).then((_) {
            if (mounted) {
              setState(() {
                _showContainer = true;
              });
              _containerController.forward();
            }
          });
        });
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _containerController.dispose();
    _usernameController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _onNameChange(bool isValid) {
    setState(() {
      _isNameValid = isValid;
    });
  }

  void _onUsernameChange(bool isValid) {
    setState(() {
      _isUsernameValid = isValid;
    });
  }

  void _onContinue() {
    BlocProvider.of<UserBloc>(context).add(
      CreateUser(
        name: _nameController.text.trim(),
        username: _usernameController.text.trim(),
        userType: _userType,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is NoCurrentUser) {
          if (state.exception is UsernameAlreadyTakenException) {
            _bottomCaptionText = 'El nombre de usuario ya esta en uso.';
          } else if (state.exception != null) {
            _bottomCaptionText = 'Algo salio mal, intentalo de nuevo mas tarde';
          } else {
            _bottomCaptionText = null;
          }
          _isLoading = state.isCreating;
          _userType = state.userType!;
        }

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!_showContainer)
                  FadeTransition(
                    opacity: _titleAnimation,
                    child: const LivitText(
                      'Bienvenido a\n LIVIT',
                      textType: TextType.bigTitle,
                    ),
                  ),
                if (_showContainer)
                  Container(
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      borderRadius: LivitContainerStyle.borderRadius,
                    ),
                    child: SlideTransition(
                      position: _containerAnimation,
                      child: Padding(
                        padding: LivitContainerStyle.paddingFromScreen,
                        child: GlassContainer(
                          child: Column(
                            children: [
                              const TitleBar(title: 'Define tu nombre y usuario'),
                              Padding(
                                padding: LivitContainerStyle.padding([0, null, null, null]),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    LivitTextField(
                                      controller: _nameController,
                                      hint: 'Nombre o apodo',
                                      onChanged: _onNameChange,
                                      regExp: RegExp(r'^[a-zA-Z_ ]{3,30}$'),
                                    ),
                                    LivitSpaces.m,
                                    const LivitText(
                                      'Como quieres que te llamen?, debe tener entre 3 y 30 caracteres o espacios.',
                                      textType: TextType.small,
                                      color: LivitColors.whiteInactive,
                                    ),
                                    LivitSpaces.m,
                                    LivitTextField(
                                      controller: _usernameController,
                                      hint: 'Nombre de usuario',
                                      onChanged: _onUsernameChange,
                                      regExp: RegExp(r'^[a-zA-Z0-9_]{6,15}$'),
                                      bottomCaptionText: _bottomCaptionText,
                                    ),
                                    LivitSpaces.m,
                                    const LivitText(
                                      'El nombre de usuario debe tener entre 6 y 15 caracteres y solo puede contener letras, números y guiones bajos. Intenta que sea facil de recordar.',
                                      textType: TextType.small,
                                      color: LivitColors.whiteInactive,
                                    ),
                                    LivitSpaces.m,
                                    Button.main(
                                      text: _isLoading ? 'Creando usuario' : 'Crear usuario',
                                      isLoading: _isLoading,
                                      isActive: _isNameValid && _isUsernameValid,
                                      onPressed: () => _onContinue(),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
