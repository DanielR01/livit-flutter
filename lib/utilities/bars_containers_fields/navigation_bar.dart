import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:livit/constants/colors.dart';
import 'package:livit/constants/styles/bar_style.dart';
import 'package:livit/constants/styles/button_style.dart';
import 'package:livit/constants/styles/container_style.dart';

List<String> navIcons = [
  "assets/icons/home.svg",
  "assets/icons/binoculars.svg",
  "assets/icons/tickets.svg",
  "assets/icons/profile.svg",
];

class LivitNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onItemTapped;
  final List<IconData> iconList;

  LivitNavigationBar.promoter({
    super.key,
    required this.currentIndex,
    required this.onItemTapped,
  }) : iconList = [
          CupertinoIcons.building_2_fill,
          CupertinoIcons.calendar,
          CupertinoIcons.tickets_fill,
          CupertinoIcons.person_fill,
        ];

  //TODO: Add customer icons
  LivitNavigationBar.customer({
    super.key,
    required this.currentIndex,
    required this.onItemTapped,
  }) : iconList = [
          CupertinoIcons.building_2_fill,
          CupertinoIcons.calendar,
          CupertinoIcons.tickets_fill,
          CupertinoIcons.person_fill,
        ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: LivitBarStyle.height,
      margin: EdgeInsets.only(
        right: LivitContainerStyle.paddingFromScreen.right,
        left: LivitContainerStyle.paddingFromScreen.left,
        bottom: LivitContainerStyle.verticalPadding,
      ),
      decoration: BoxDecoration(
        color: LivitColors.mainBlack,
        borderRadius: LivitContainerStyle.borderRadius,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: iconList
            .map(
              (icon) => GestureDetector(
                onTap: () => onItemTapped(iconList.indexOf(icon)),
                child: Container(
                  color: Colors.transparent,
                  height: LivitBarStyle.height,
                  width: LivitBarStyle.height,
                  child: Icon(
                    icon,
                    color: currentIndex == iconList.indexOf(icon) ? LivitColors.whiteActive : LivitColors.whiteInactive,
                    size: LivitButtonStyle.bigIconSize,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
