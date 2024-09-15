import 'package:flutter/cupertino.dart';


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
        
        Center(
          child: Text('Explore'),
        ),
      ],
    );
  }
}
