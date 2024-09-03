import 'package:flutter/cupertino.dart';
import 'package:livit/utilities/background/main_background.dart';

class ExploreView extends StatefulWidget {
  
  const ExploreView({super.key, });

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
