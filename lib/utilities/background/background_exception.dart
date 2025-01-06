import 'package:livit/services/exceptions/base_exception.dart';

class BackgroundException extends LivitException {
  BackgroundException(
    super.message, {
    super.showToUser = false,
    super.technicalDetails,
    super.severity = ErrorSeverity.normal,
  });
}

class BackgroundPreloadException extends BackgroundException {
  BackgroundPreloadException({String? details})
      : super(
          'Error preloading cached background',
          showToUser: false,
          technicalDetails: details,
          severity: ErrorSeverity.normal,
        );
}

class BackgroundGenerateException extends BackgroundException {
  BackgroundGenerateException({String? details})
      : super(
          'Error generating cached background',
          showToUser: false,
          technicalDetails: details,
          severity: ErrorSeverity.normal,
        );
}

class BackgroundCouldNotInitCachedBackgroundException extends BackgroundException {
  BackgroundCouldNotInitCachedBackgroundException({String? details})
      : super(
          'Could not init cached background',
          showToUser: false,
          technicalDetails: details,
          severity: ErrorSeverity.normal,
        );
}
