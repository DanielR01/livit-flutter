import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/services/auth/bloc/auth_bloc.dart';
import 'package:livit/services/auth/bloc/auth_event.dart';
import 'package:livit/services/error_reporting/error_reporter.dart';
import 'package:livit/services/firestore_storage/firestore_storage/exceptions/firestore_exceptions.dart';
import 'package:livit/utilities/buttons/button.dart';
import 'package:livit/utilities/debug/livit_debugger.dart';

class ErrorReauthScreen extends StatefulWidget {
  final Exception exception;
  const ErrorReauthScreen({super.key, required this.exception});

  @override
  State<ErrorReauthScreen> createState() => _ErrorReauthScreenState();
}

class _ErrorReauthScreenState extends State<ErrorReauthScreen> {
  final _errorReporter = ErrorReporter(viewName: 'ErrorReauthScreen');
  final _debugger = LivitDebugger('ErrorReauthScreen');

  @override
  void initState() {
    super.initState();
    _debugger.debPrint('Showing error: ${widget.exception}', DebugMessageType.error);
    _reportError();
  }

  Future<void> _reportError() async {
    _debugger.debPrint('Reporting error to crash analytics', DebugMessageType.uploading);
    await _errorReporter.reportError(
      widget.exception is FirestoreException ? widget.exception : GenericFirestoreException(details: widget.exception.toString()),
      StackTrace.current,
      reason: widget.exception is FirestoreException ? (widget.exception as FirestoreException).technicalDetails : null,
    );
  }

  void _handleLogout() {
    _debugger.debPrint('User logging out after error', DebugMessageType.info);
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
                  onTap: _handleLogout,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
