import 'package:flutter/material.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/styles/button_style.dart';
import 'package:livit/constants/styles/shadows.dart';

class ToggleButton extends StatefulWidget {
  final bool initialValue;
  final Function(bool) onToggle;
  final Color activeColor;
  final Color inactiveColor;
  final Color activeThumbColor;
  final Color inactiveThumbColor;
  final double width;
  final double height;
  final bool isActive;

  const ToggleButton({
    super.key,
    this.initialValue = false,
    required this.onToggle,
    this.activeColor = LivitColors.mainBlack,
    this.inactiveColor = LivitColors.mainBlack,
    this.activeThumbColor = LivitColors.mainBlueActive,
    this.inactiveThumbColor = LivitColors.mainBlueInactive,
    this.width = 56.0,
    this.height = 30.0,
    this.isActive = true,
  });

  @override
  State<ToggleButton> createState() => _ToggleButtonState();
}

class _ToggleButtonState extends State<ToggleButton> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _slideAnimation;
  late final Animation<Color?> _colorAnimation;
  late final Animation<Color?> _thumbColorAnimation;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _isActive = widget.initialValue;

    // Set up animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    // If initially active, set the controller to end position
    if (_isActive) {
      _animationController.value = 1.0;
    }

    // Create animations
    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: widget.width - widget.height,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _colorAnimation = ColorTween(
      begin: widget.inactiveColor,
      end: widget.activeColor,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _thumbColorAnimation = ColorTween(
      begin: widget.inactiveThumbColor,
      end: widget.activeThumbColor,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Force rebuild on animation changes
    _animationController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggle() {
    if (!widget.isActive) return;
    setState(() {
      _isActive = !_isActive;
      if (_isActive) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
      widget.onToggle(_isActive);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: _colorAnimation.value,
          borderRadius: BorderRadius.circular(widget.height / 2),
          boxShadow: [
            _isActive ? LivitShadows.activeBlueShadow : LivitShadows.inactiveBlueShadow,
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Stack(
            children: [
              Positioned(
                left: _slideAnimation.value,
                child: Container(
                  width: widget.height - 4,
                  height: widget.height - 4,
                  decoration: BoxDecoration(
                    color: _thumbColorAnimation.value,
                    shape: BoxShape.circle,
                    boxShadow: [
                      // LivitShadows.activeBlueShadow,
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
