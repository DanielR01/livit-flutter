import 'package:livit/services/background/background_states.dart';

abstract class BackgroundEvent {}

class BackgroundStartLoadingAnimation extends BackgroundEvent {
  final bool overrideLock;
  BackgroundStartLoadingAnimation({this.overrideLock = false});
}

class BackgroundSpeedNormal extends BackgroundEvent {
  final bool overrideLock;  
  BackgroundSpeedNormal({this.overrideLock = false});
}

class BackgroundSpeedMax extends BackgroundEvent {
  final bool overrideLock;
  BackgroundSpeedMax({this.overrideLock = false});
}

class BackgroundSpeedSlow extends BackgroundEvent {
  final bool overrideLock;
  BackgroundSpeedSlow({this.overrideLock = false});
}

class BackgroundSpeedMin extends BackgroundEvent {
  final bool overrideLock;
  BackgroundSpeedMin({this.overrideLock = false});
}

class BackgroundStopLoadingAnimation extends BackgroundEvent {
  final bool overrideLock;
  BackgroundStopLoadingAnimation({this.overrideLock = false});
}

class BackgroundSetMode extends BackgroundEvent {
  final BackgroundMode mode;
  BackgroundSetMode(this.mode);
}

class BackgroundResume extends BackgroundEvent {
  final bool overrideLock;
  BackgroundResume({this.overrideLock = false});
}

class BackgroundGeneratedBackground extends BackgroundEvent {}

class BackgroundOnOrigin extends BackgroundEvent {}

class BackgroundStartTransitionAnimation extends BackgroundEvent {
  final bool overrideLock;
  BackgroundStartTransitionAnimation({this.overrideLock = false});
}

class BackgroundStopTransitionAnimation extends BackgroundEvent {
  final bool overrideLock;
  BackgroundStopTransitionAnimation({this.overrideLock = false});
}

class BackgroundLockSpeed extends BackgroundEvent {
  final AnimationSpeed speed;
  final double interpolationSpeed;
  BackgroundLockSpeed(this.speed, this.interpolationSpeed);
}

class BackgroundUnlockSpeed extends BackgroundEvent {}
