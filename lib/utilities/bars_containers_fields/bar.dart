import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/styles/bar_style.dart';
import 'package:livit/constants/styles/button_style.dart';
import 'package:livit/constants/styles/container_style.dart';
import 'package:livit/constants/styles/livit_text.dart';
import 'package:livit/constants/styles/spaces.dart';
import 'package:livit/utilities/buttons/button.dart';

class LivitBar extends StatefulWidget {
  final Widget? child;
  final IconData? icon;
  final ShadowType shadowType;
  final bool noPadding;
  final bool isTouchable;
  final bool isExpandable;
  final bool isTransparent;
  final Function()? onTap;

  final List<Button>? buttons;
  final String? titleText;

  const LivitBar({super.key, required this.child, this.shadowType = ShadowType.normal, this.noPadding = false})
      : isTouchable = false,
        isExpandable = false,
        onTap = null,
        isTransparent = false,
        buttons = null,
        titleText = null,
        icon = null;

  const LivitBar.touchable({
    super.key,
    required this.child,
    this.shadowType = ShadowType.normal,
    this.noPadding = false,
    required this.onTap,
    this.isTouchable = true,
    this.isTransparent = false,
  })  : buttons = null,
        titleText = null,
        isExpandable = false,
        icon = null;

  const LivitBar.expandable({
    super.key,
    this.shadowType = ShadowType.weak,
    this.isTransparent = false,
    required this.buttons,
    required this.titleText,
    this.icon,
  })  : noPadding = true,
        isTouchable = false,
        isExpandable = true,
        child = null,
        onTap = null;

  const LivitBar.expandableWithCustomChild({
    super.key,
    this.shadowType = ShadowType.weak,
    this.isTransparent = false,
    required this.buttons,
    required this.child,
  })  : noPadding = true,
        isTouchable = false,
        isExpandable = true,
        titleText = null,
        icon = null,
        onTap = null;

  @override
  State<LivitBar> createState() => _LivitBarState();
}

class _LivitBarState extends State<LivitBar> {
  bool _isExpanded = false;
  double? _buttonsWidth;
  double? _buttonsHeight;
  final GlobalKey _buttonsKey = GlobalKey();

  late ShadowType _shadowType;

  @override
  void initState() {
    super.initState();
    _shadowType = widget.shadowType;
  }

  void _updateButtonsSize() {
    if (_buttonsKey.currentContext != null) {
      final RenderBox renderBox = _buttonsKey.currentContext!.findRenderObject() as RenderBox;
      setState(
        () {
          _buttonsWidth = renderBox.size.width;
          _buttonsHeight = renderBox.size.height;
        },
      );
    }
  }

  void _toggleExpandable() {
    setState(() {
      _isExpanded = !_isExpanded;
      _updateButtonsSize();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isTouchable) {
      return Container(
        width: double.infinity,
        constraints: BoxConstraints(minHeight: LivitBarStyle.height),
        decoration: LivitBarStyle.decoration(isTransparent: widget.isTransparent, shadowType: _shadowType),
        child: Material(
          color: widget.isTransparent ? Colors.transparent : LivitColors.mainBlack,
          borderRadius: LivitBarStyle.borderRadius,
          child: InkWell(
            borderRadius: LivitBarStyle.borderRadius,
            onTap: widget.onTap,
            child: widget.child,
          ),
        ),
      );
    }

    if (widget.isExpandable && widget.child == null) {
      return _buildExpandableBar();
    } else if (widget.isExpandable && widget.child != null) {
      return _buildExpandableWithCustomChild();
    }

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: LivitBarStyle.height),
      decoration: _shadowType == ShadowType.strong
          ? LivitBarStyle.strongShadowDecoration
          : _shadowType == ShadowType.normal
              ? LivitBarStyle.normalShadowDecoration
              : _shadowType == ShadowType.weak
                  ? LivitBarStyle.weakShadowDecoration
                  : LivitBarStyle.normalDecoration,
      child: Padding(
        padding: widget.noPadding ? EdgeInsets.zero : LivitContainerStyle.padding(),
        child: widget.child,
      ),
    );
  }

  Widget _buildExpandableBar() {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: widget.titleText ?? '',
        style: LivitTextStyle.smallTitleWhiteActiveText,
      ),
      textDirection: TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    );

    textPainter.layout();
    final double titleTextWidth = textPainter.width;
    final double iconWidth = widget.icon != null ? LivitButtonStyle.iconSize + LivitSpaces.xsDouble : 0;
    final double totalTitleWidth = titleTextWidth + iconWidth;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double barWidth = constraints.maxWidth;
        final double availableBarWidth = barWidth - LivitContainerStyle.horizontalPadding * 2;
        final double titleTextPosition = barWidth / 2 - LivitContainerStyle.horizontalPadding - totalTitleWidth / 2;

        final buttonsContainer = Opacity(
          opacity: 0,
          child: Container(
            color: Colors.red.withOpacity(0.5),
            key: _buttonsKey,
            constraints: BoxConstraints(maxWidth: availableBarWidth),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  CupertinoIcons.chevron_right,
                  size: LivitButtonStyle.iconSize,
                  color: LivitColors.whiteActive,
                ),
                LivitSpaces.xs,
                Flexible(
                  child: Wrap(
                    spacing: LivitSpaces.sDouble,
                    runSpacing: LivitSpaces.sDouble,
                    children: widget.buttons ?? [],
                  ),
                ),
              ],
            ),
          ),
        );

        // Calculate available width for title when expanded
        final availableTitleWidth = availableBarWidth - (_isExpanded ? _buttonsWidth ?? 0 : 0);

        // Determine if we need to hide the icon when expanded
        final bool shouldHideIconWhenExpanded = _isExpanded && totalTitleWidth > availableTitleWidth && widget.icon != null;

        // Calculate available width for text based on whether icon is shown
        final double availableTextWidth =
            shouldHideIconWhenExpanded ? availableTitleWidth : availableTitleWidth - (widget.icon != null ? iconWidth : 0);

        return Container(
          width: double.infinity,
          decoration: LivitBarStyle.decoration(isTransparent: widget.isTransparent, shadowType: widget.shadowType),
          child: Material(
            color: widget.isTransparent ? Colors.transparent : LivitColors.mainBlack,
            borderRadius: LivitBarStyle.borderRadius,
            child: InkWell(
              borderRadius: LivitBarStyle.borderRadius,
              onTap: _toggleExpandable,
              child: Container(
                constraints: BoxConstraints(
                  minHeight: LivitBarStyle.height,
                  maxWidth: constraints.maxWidth,
                ),
                padding: LivitContainerStyle.padding(padding: [0, null, 0, null]),
                child: Stack(
                  alignment: Alignment.centerRight,
                  clipBehavior: Clip.none,
                  children: [
                    AnimatedPositioned(
                      duration: kThemeAnimationDuration,
                      left: _isExpanded ? 0 : titleTextPosition,
                      child: Container(
                        constraints: _isExpanded
                            ? BoxConstraints(
                                maxWidth: max(availableTitleWidth, 0),
                              )
                            : null,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: max(0, availableTextWidth),
                              ),
                              child: LivitText(
                                widget.titleText ?? '',
                                textType: LivitTextType.smallTitle,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (widget.icon != null && !shouldHideIconWhenExpanded) ...[
                              LivitSpaces.xs,
                              Icon(
                                widget.icon!,
                                size: LivitButtonStyle.iconSize,
                                color: LivitColors.whiteActive,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: availableBarWidth,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedRotation(
                            duration: kThemeAnimationDuration,
                            turns: _isExpanded ? 0 : 0.5,
                            child: Icon(
                              CupertinoIcons.chevron_right,
                              size: LivitButtonStyle.iconSize,
                              color: LivitColors.whiteActive,
                            ),
                          ),
                          Flexible(
                            child: AnimatedSize(
                              duration: kThemeAnimationDuration,
                              alignment: Alignment.centerRight,
                              child: AnimatedOpacity(
                                duration: kThemeAnimationDuration,
                                opacity: _isExpanded ? 1 : 0,
                                child: _isExpanded
                                    ? Padding(
                                        padding: LivitContainerStyle.padding(
                                          padding: [
                                            (_buttonsHeight ?? 0) > LivitButtonStyle.height ? null : 0,
                                            0,
                                            (_buttonsHeight ?? 0) > LivitButtonStyle.height ? null : 0,
                                            LivitSpaces.xsDouble,
                                          ],
                                        ),
                                        child: Wrap(
                                          spacing: LivitSpaces.sDouble,
                                          runSpacing: LivitSpaces.sDouble,
                                          children: widget.buttons ?? [],
                                        ),
                                      )
                                    : SizedBox.shrink(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 0,
                      child: IgnorePointer(child: buttonsContainer),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExpandableWithCustomChild() {
    return Container(
      width: double.infinity,
      decoration: LivitBarStyle.decoration(isTransparent: widget.isTransparent, shadowType: ShadowType.weak),
      child: Material(
        color: widget.isTransparent ? Colors.transparent : LivitColors.mainBlack,
        borderRadius: LivitBarStyle.borderRadius,
        child: InkWell(
          borderRadius: LivitBarStyle.borderRadius,
          onTap: _toggleExpandable,
          child: Container(
            constraints: BoxConstraints(
              minHeight: LivitBarStyle.height,
            ),
            padding: LivitContainerStyle.padding(padding: [0, null, 0, null]),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  alignment: Alignment.centerRight,
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: 0,
                      child: Opacity(
                        opacity: _isExpanded ? 0 : 1,
                        child: IgnorePointer(
                          ignoring: _isExpanded,
                          child: widget.child!,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AnimatedRotation(
                          duration: kThemeAnimationDuration,
                          turns: _isExpanded ? 0 : 0.5,
                          child: Icon(
                            CupertinoIcons.chevron_right,
                            size: LivitButtonStyle.iconSize,
                            color: LivitColors.whiteActive,
                          ),
                        ),
                        AnimatedSize(
                          duration: kThemeAnimationDuration,
                          alignment: Alignment.centerRight,
                          child: SizedBox(
                            width: _isExpanded ? constraints.maxWidth - LivitButtonStyle.iconSize : 0,
                            child: AnimatedOpacity(
                              duration: kThemeAnimationDuration,
                              opacity: _isExpanded ? 1 : 0,
                              child: _isExpanded
                                  ? Padding(
                                      padding: LivitContainerStyle.padding(padding: [
                                        (_buttonsHeight ?? 0) > LivitButtonStyle.height ? null : 0,
                                        0,
                                        (_buttonsHeight ?? 0) > LivitButtonStyle.height ? null : 0,
                                        LivitSpaces.xsDouble
                                      ]),
                                      child: Wrap(
                                        spacing: LivitSpaces.sDouble,
                                        runSpacing: LivitSpaces.sDouble,
                                        children: widget.buttons ?? [],
                                      ),
                                    )
                                  : SizedBox.shrink(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
