import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/services/auth/bloc/auth_bloc.dart';
import 'package:livit/services/auth/bloc/auth_event.dart';
import 'package:livit/services/auth/bloc/auth_state.dart';
import 'package:livit/services/error_reporting/error_reporter.dart';
import 'package:livit/services/firestore_storage/firestore_storage/exceptions/firestore_exceptions.dart';
import 'package:livit/utilities/buttons/button.dart';
import 'package:livit/views/auth/login/welcome.dart';

class ErrorReauthScreen extends StatefulWidget {
  final Exception exception;
  const ErrorReauthScreen({super.key, required this.exception});

  @override
  State<ErrorReauthScreen> createState() => _ErrorReauthScreenState();
}

class _ErrorReauthScreenState extends State<ErrorReauthScreen> {
  final _errorReporter = ErrorReporter();

  @override
  void initState() {
    super.initState();
    debugPrint('🚨 [ErrorReauthScreen] Showing error: ${widget.exception}');
    _reportError();
  }

  Future<void> _reportError() async {
    debugPrint('📤 [ErrorReauthScreen] Reporting error to crash analytics');
    await _errorReporter.reportError(
      widget.exception is FirestoreException ? widget.exception : GenericFirestoreException(details: widget.exception.toString()),
      StackTrace.current,
      reason: widget.exception is FirestoreException ? (widget.exception as FirestoreException).technicalDetails : null,
    );
  }

  void _handleLogout() {
    debugPrint('🚪 [ErrorReauthScreen] User logging out after error');
    context.read<AuthBloc>().add(AuthEventLogOut(context));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: LivitContainerStyle.paddingFromScreen,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const LivitText(
                  '¡Ups!',
                  textType: LivitTextType.bigTitle,
                ),
                LivitSpaces.xs,
                const LivitText(
                  'Algo salió mal, intenta iniciar sesión de nuevo.',
                  textAlign: TextAlign.center,
                ),
                LivitSpaces.s,
                // LivitText(
                //   widget.exception.toString(),
                //   textAlign: TextAlign.center,
                //   textType: LivitTextType.small,
                // ),
                // LivitSpaces.m,
                Button.main(
                  isActive: true,
                  text: 'Iniciar sesión de nuevo',
                  onPressed: _handleLogout,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
