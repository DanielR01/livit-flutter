enum BackgroundMode { static, dynamic }

enum AnimationSpeed {
  stopped(0),
  verySlow(1 / 3),
  slow(1 / 2),
  normal(1),
  intermediate(1.5),
  fast(5.0),
  veryFast(7.0);

  final double value;
  const AnimationSpeed(this.value);
}

class BackgroundState {
  final AnimationSpeed speed;
  final double interpolationSpeed;
  final BackgroundMode mode;
  final bool isGoingToOrigin;
  final bool isBackgroundGenerated;
  const BackgroundState({
    required this.speed,
    required this.interpolationSpeed,
    required this.mode,
    this.isGoingToOrigin = false,
    this.isBackgroundGenerated = false,
  });

  BackgroundState copyWith({
    AnimationSpeed? speed,
    double? interpolationSpeed,
    BackgroundMode? mode,
    bool? isGoingToOrigin,
    bool? isBackgroundGenerated,
  }) {
    return BackgroundState(
      speed: speed ?? this.speed,
      interpolationSpeed: interpolationSpeed ?? this.interpolationSpeed,
      mode: mode ?? this.mode,
      isGoingToOrigin: isGoingToOrigin ?? this.isGoingToOrigin,
      isBackgroundGenerated: isBackgroundGenerated ?? this.isBackgroundGenerated,
    );
  }

  @override
  String toString() {
    return 'BackgroundState(speed: $speed, interpolationSpeed: $interpolationSpeed, mode: $mode, isGoingToOrigin: $isGoingToOrigin, isBackgroundGenerated: $isBackgroundGenerated)';
  }
}
