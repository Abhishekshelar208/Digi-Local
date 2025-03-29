

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../pages/fullscreenimageview.dart';

class EventSliderForDesigeOne extends StatefulWidget {
  final List<Map<String, dynamic>> events;

  EventSliderForDesigeOne({required this.events});

  @override
  _EventSliderForDesigeOneState createState() =>
      _EventSliderForDesigeOneState();
}

class _EventSliderForDesigeOneState extends State<EventSliderForDesigeOne> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  double currentPage = 0.0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        currentPage = _pageController.page ?? 0;
      });
    });
  }

  void _launchURL(String url) async {
    if (url.isNotEmpty) {
      Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        print("Could not launch $url");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isDesktop = constraints.maxWidth > 800;
        return Column(
          children: [
            SizedBox(
              height: isDesktop ? 600 : 450,
              child: isDesktop
                  ? GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 25,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.9,    //adjust the height of the card for PC here.
                ),
                itemCount: widget.events.length,
                itemBuilder: (context, index) {
                  return _buildProjectCard(index, isDesktop);
                },
              )
                  : PageView.builder(
                controller: _pageController,
                itemCount: widget.events.length,
                physics: BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  double scale = (index == currentPage.round()) ? 0.92 : 0.8;   //adjust the height of the card for mobile here.
                  return TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0.9, end: scale),
                    duration: Duration(milliseconds: 300),
                    builder: (context, double scale, child) {
                      return Transform.scale(
                        scale: scale,
                        child: _buildProjectCard(index, isDesktop),
                      );
                    },
                  );
                },
              ),
            ),
            if (!isDesktop) ...[
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.events.length, (index) {
                  bool isActive = index == currentPage.round();
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 12 : 8,
                    height: isActive ? 12 : 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive ? Colors.white : Colors.grey,
                    ),
                  );
                }),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildProjectCard(int index, bool isDesktop) {
    return MouseRegion(
      onEnter: (_) => setState(() {}),
      onExit: (_) => setState(() {}),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        transform: Matrix4.translationValues(0, 0, 0)..scale(1.02),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: Offset(3, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image with overlay
              if (widget.events[index]["image"] != null &&
                  widget.events[index]["image"].isNotEmpty)
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => FullScreenImageView(
                        imageUrl: widget.events[index]["image"],
                      ),
                    );
                  },
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(
                          widget.events[index]["image"],
                          width: double.infinity,
                          height: isDesktop ? 280 : 200,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.image_not_supported,
                            size: 50,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            gradient: LinearGradient(
                              colors: [Colors.black54, Colors.transparent],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(height: 12),
              // Project title
              Text(
                widget.events[index]["title"] ?? "No Title",
                style: GoogleFonts.blinker(
                  fontSize: 22,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 6),
              // Description
              Text(
                widget.events[index]["description"] ?? "No Description",
                style: GoogleFonts.blinker(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 10),
              // // Product price
              // Text(
              //   "Price: ${widget.events[index]["productprice"] ?? "No Price"}",
              //   style: GoogleFonts.blinker(
              //     fontSize: 18,
              //     color: Colors.black87,
              //     fontWeight: FontWeight.w600,
              //   ),
              // ),
              // SizedBox(height: 12),
              // // Buy Now button
              // Align(
              //   alignment: Alignment.center,
              //   child: ElevatedButton.icon(
              //     onPressed: () {
              //       final url = widget.events[index]["purchaseLink"] ?? "";
              //       _launchURL(url);
              //     },
              //     icon: Icon(Icons.shopping_cart, color: Colors.white),
              //     label: Text(
              //       "Buy Now",
              //       style: GoogleFonts.blinker(
              //         fontSize: 15,
              //         fontWeight: FontWeight.w500,
              //         color: Colors.white,
              //       ),
              //     ),
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: Colors.black,
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(30),
              //       ),
              //       padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
