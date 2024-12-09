import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:livit/constants/colors.dart';

const double _kScrollbarMinLength = 36.0;
const double _kScrollbarMinOverscrollLength = 8.0;
const Duration _kScrollbarTimeToFade = Duration(milliseconds: 1200);
const Duration _kScrollbarFadeDuration = Duration(milliseconds: 250);
const Duration _kScrollbarResizeDuration = Duration(milliseconds: 100);

Color _kScrollbarColor = LivitColors.whiteInactive.withOpacity(0.6);

const double _kScrollbarMainAxisMargin = 3.0;
const double _kScrollbarCrossAxisMargin = 3.0;

class LivitScrollbar extends RawScrollbar {
  const LivitScrollbar({
    super.key,
    required super.child,
    super.controller,
    bool? thumbVisibility,
    double super.thickness = defaultThickness,
    this.thicknessWhileDragging = defaultThicknessWhileDragging,
    Radius super.radius = defaultRadius,
    this.radiusWhileDragging = defaultRadiusWhileDragging,
    ScrollNotificationPredicate? notificationPredicate,
    super.scrollbarOrientation,
  })  : assert(thickness < double.infinity),
        assert(thicknessWhileDragging < double.infinity),
        super(
          thumbVisibility: thumbVisibility ?? false,
          fadeDuration: _kScrollbarFadeDuration,
          timeToFade: _kScrollbarTimeToFade,
          pressDuration: const Duration(milliseconds: 100),
          notificationPredicate: notificationPredicate ?? defaultScrollNotificationPredicate,
        );

  static const double defaultThickness = 3;

  static const double defaultThicknessWhileDragging = 8.0;

  static const Radius defaultRadius = Radius.circular(1.5);

  static const Radius defaultRadiusWhileDragging = Radius.circular(4.0);

  final double thicknessWhileDragging;

  final Radius radiusWhileDragging;

  @override
  RawScrollbarState<LivitScrollbar> createState() => _LivitScrollbarState();
}

class _LivitScrollbarState extends RawScrollbarState<LivitScrollbar> {
  late AnimationController _thicknessAnimationController;

  double get _thickness {
    return widget.thickness! + _thicknessAnimationController.value * (widget.thicknessWhileDragging - widget.thickness!);
  }

  Radius get _radius {
    return Radius.lerp(widget.radius, widget.radiusWhileDragging, _thicknessAnimationController.value)!;
  }

  @override
  void initState() {
    super.initState();
    _thicknessAnimationController = AnimationController(
      vsync: this,
      duration: _kScrollbarResizeDuration,
    );
    _thicknessAnimationController.addListener(() {
      updateScrollbarPainter();
    });
  }

  @override
  void updateScrollbarPainter() {
    scrollbarPainter
      ..color = CupertinoDynamicColor.resolve(_kScrollbarColor, context)
      ..textDirection = Directionality.of(context)
      ..thickness = _thickness
      ..mainAxisMargin = _kScrollbarMainAxisMargin
      ..crossAxisMargin = _kScrollbarCrossAxisMargin
      ..radius = _radius
      ..padding = MediaQuery.paddingOf(context)
      ..minLength = _kScrollbarMinLength
      ..minOverscrollLength = _kScrollbarMinOverscrollLength
      ..scrollbarOrientation = widget.scrollbarOrientation;
  }

  double _pressStartAxisPosition = 0.0;

  @override
  void handleThumbPressStart(Offset localPosition) {
    super.handleThumbPressStart(localPosition);
    final Axis? direction = getScrollbarDirection();
    if (direction == null) {
      return;
    }
    _pressStartAxisPosition = switch (direction) {
      Axis.vertical => localPosition.dy,
      Axis.horizontal => localPosition.dx,
    };
  }

  @override
  void handleThumbPress() {
    if (getScrollbarDirection() == null) {
      return;
    }
    super.handleThumbPress();
    _thicknessAnimationController.forward().then<void>(
          (_) => HapticFeedback.mediumImpact(),
        );
  }

  @override
  void handleThumbPressEnd(Offset localPosition, Velocity velocity) {
    final Axis? direction = getScrollbarDirection();
    if (direction == null) {
      return;
    }
    _thicknessAnimationController.reverse();
    super.handleThumbPressEnd(localPosition, velocity);
    final (double axisPosition, double axisVelocity) = switch (direction) {
      Axis.horizontal => (localPosition.dx, velocity.pixelsPerSecond.dx),
      Axis.vertical => (localPosition.dy, velocity.pixelsPerSecond.dy),
    };
    if (axisPosition != _pressStartAxisPosition && axisVelocity.abs() < 10) {
      HapticFeedback.mediumImpact();
    }
  }

  @override
  void dispose() {
    _thicknessAnimationController.dispose();
    super.dispose();
  }
}
