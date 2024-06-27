import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:livit/constants/colors.dart';

List<String> navIcons = [
  "assets/icons/home.svg",
  "assets/icons/binoculars.svg",
  "assets/icons/tickets.svg",
  "assets/icons/profile.svg",
];

class CustomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onItemTapped;

  const CustomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      margin: const EdgeInsets.only(
        right: 10,
        left: 10,
        bottom: 16,
      ),
      decoration: BoxDecoration(
        color: LivitColors.mainBlack,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: navIcons.map(
          (icon) {
            int index = navIcons.indexOf(icon);
            bool isSelected = currentIndex == index;
            return Material(
              color: Colors.transparent,
              child: GestureDetector(
                onTap: () => onItemTapped(index),
                child: Container(
                  height: 40,
                  width: 40,
                  alignment: Alignment.center,
                  color: Colors.transparent,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 17,
                        child: SvgPicture.asset(
                          icon,
                          colorFilter: ColorFilter.mode(
                              isSelected
                                  ? LivitColors.whiteActive
                                  : LivitColors.whiteInactive,
                              BlendMode.srcIn),
                          height: 17,
                        ),
                      ),
                      // const SizedBox(
                      //   height: 4,
                      // ),
                      // SizedBox(
                      //   child: SvgPicture.asset(
                      //     "assets/icons/line.svg",
                      //     colorFilter: ColorFilter.mode(
                      //         isSelected
                      //             ? LivitColors.whiteActive
                      //             : Colors.transparent,
                      //         BlendMode.srcIn),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            );
          },
        ).toList(),
      ),
    );
  }
}
