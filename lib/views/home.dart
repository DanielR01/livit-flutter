import 'package:flutter/cupertino.dart';
import 'package:livit/utilities/background/main_background.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        MainBackground(),
        Center(
          child: Text('Home'),
        ),
      ],
    );
  }
}
