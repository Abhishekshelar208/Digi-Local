import 'package:flutter/cupertino.dart';

class MarqueeChips extends StatefulWidget {
  final List<Widget> chips;
  final double velocity; // Velocity in pixels per second.

  const MarqueeChips({
    Key? key,
    required this.chips,
    this.velocity = 30.0,
  }) : super(key: key);

  @override
  _MarqueeChipsState createState() => _MarqueeChipsState();
}

class _MarqueeChipsState extends State<MarqueeChips> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // Start scrolling after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startScrolling();
    });
  }

  Future<void> _startScrolling() async {
    while (mounted) {
      double distance = _scrollController.position.maxScrollExtent / 2;
      int durationMillis = ((distance / widget.velocity) * 1000).round();

      await _scrollController.animateTo(
        distance,
        duration: Duration(milliseconds: durationMillis),
        curve: Curves.linear,
      );
      _scrollController.jumpTo(0); // Reset without animation
    }
  }

  List<Widget> _generateRepeatedChips(double maxWidth) {
    List<Widget> repeatedChips = [];
    double totalWidth = 0.0;

    // Repeating chips until the total width exceeds the screen width
    while (totalWidth < maxWidth * 2) {
      for (var chip in widget.chips) {
        repeatedChips.add(Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: chip,
        ));
        totalWidth += 100; // Assuming each chip roughly takes 100 pixels (adjust if needed)
      }
    }

    return repeatedChips;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: _scrollController,
      child: Row(
        children: _generateRepeatedChips(screenWidth),
      ),
    );
  }
}
