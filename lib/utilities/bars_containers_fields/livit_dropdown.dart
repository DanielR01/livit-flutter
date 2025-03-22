import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/styles/button_style.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/constants/styles/spaces.dart';

class LivitDropdown<T> extends StatefulWidget {
  final T? value;
  final List<LivitDropdownItem<T>> items;
  final String hintText;
  final Function(T?) onChanged;
  final double width;
  final Icon? icon;
  final Color backgroundColor;
  final Color textColor;
  final Color hintColor;
  final Color borderColor;
  final EdgeInsets contentPadding;

  const LivitDropdown({
    super.key,
    required this.items,
    required this.onChanged,
    this.value,
    this.hintText = 'Select an option',
    this.width = double.infinity,
    this.icon,
    this.backgroundColor = LivitColors.mainBlack,
    this.textColor = LivitColors.whiteActive,
    this.hintColor = LivitColors.whiteInactive,
    this.borderColor = LivitColors.whiteInactive,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  @override
  State<LivitDropdown<T>> createState() => _LivitDropdownState<T>();
}

class _LivitDropdownState<T> extends State<LivitDropdown<T>> with SingleTickerProviderStateMixin {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _createOverlay() {
    if (_overlayEntry != null) return;

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return GestureDetector(
          onTap: () => _toggleDropdown(close: true),
          behavior: HitTestBehavior.translucent,
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: [
                Positioned(
                  width: size.width,
                  child: CompositedTransformFollower(
                    link: _layerLink,
                    offset: Offset(0, size.height + 5),
                    child: Material(
                      color: Colors.transparent,
                      elevation: 0,
                      child: SizeTransition(
                        sizeFactor: _expandAnimation,
                        axisAlignment: -1,
                        child: Container(
                          decoration: BoxDecoration(
                            color: widget.backgroundColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: widget.borderColor.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: widget.items.map((item) {
                              return InkWell(
                                onTap: () {
                                  widget.onChanged(item.value);
                                  _toggleDropdown(close: true);
                                },
                                child: Container(
                                  padding: widget.contentPadding,
                                  decoration: BoxDecoration(
                                    color: widget.value == item.value ? LivitColors.mainBlueInactive.withOpacity(0.2) : Colors.transparent,
                                    border: Border(
                                      bottom: BorderSide(
                                        color: widget.borderColor.withOpacity(0.1),
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      if (widget.value == item.value) ...[
                                        Icon(
                                          CupertinoIcons.checkmark_alt_circle,
                                          color: LivitColors.mainBlueActive,
                                          size: LivitButtonStyle.iconSize,
                                        ),
                                        LivitSpaces.xs,
                                      ],
                                      Expanded(
                                        child: LivitText(
                                          item.text,
                                          color: widget.value == item.value ? LivitColors.mainBlueActive : widget.textColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
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

  void _toggleDropdown({bool close = false}) {
    if (close) {
      _removeOverlay();
      return;
    }

    if (_isOpen) {
      _removeOverlay();
    } else {
      _createOverlay();
      _overlayEntry != null ? Overlay.of(context).insert(_overlayEntry!) : null;
      _animationController.forward();
    }

    setState(() {
      _isOpen = !_isOpen;
    });
  }

  void _removeOverlay() {
    _animationController.reverse().then((value) {
      if (_overlayEntry != null) {
        _overlayEntry!.remove();
        _overlayEntry = null;
      }
    });

    setState(() {
      _isOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Find the selected item to display its text
    final selectedItem = widget.items.firstWhere(
      (item) => item.value == widget.value,
      orElse: () => LivitDropdownItem(value: null, text: widget.hintText),
    );

    final text = widget.value != null ? selectedItem.text : widget.hintText;
    final displayColor = widget.value != null ? widget.textColor : widget.hintColor;

    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: () => _toggleDropdown(),
        child: Container(
          width: widget.width,
          padding: widget.contentPadding,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.borderColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: LivitText(
                  text,
                  color: displayColor,
                ),
              ),
              Icon(
                _isOpen ? CupertinoIcons.chevron_up : CupertinoIcons.chevron_down,
                color: widget.textColor,
                size: LivitButtonStyle.iconSize,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LivitDropdownItem<T> {
  final T? value;
  final String text;

  LivitDropdownItem({
    required this.value,
    required this.text,
  });
}
