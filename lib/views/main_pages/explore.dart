import 'package:flutter/cupertino.dart';
import 'package:livit/services/crud/tables/users/user.dart';
import 'package:livit/utilities/background/main_background.dart';

class ExploreView extends StatefulWidget {
  final LivitUser? user;
  const ExploreView({super.key, required this.user,});

  @override
  State<ExploreView> createState() => _ExploreViewState();
}

class _ExploreViewState extends State<ExploreView> {
  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        MainBackground(),
        Center(
          child: Text('Explore'),
        ),
      ],
    );
  }
}
