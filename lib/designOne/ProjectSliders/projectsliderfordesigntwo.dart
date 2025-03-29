import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../pages/fullscreenimageview.dart';


class ProjectSliderForDesignTwo extends StatefulWidget {
  final List<Map<String, dynamic>> projects; // Projects data

  ProjectSliderForDesignTwo({required this.projects});

  @override
  _ProjectSliderForDesignTwoState createState() => _ProjectSliderForDesignTwoState();
}

class _ProjectSliderForDesignTwoState extends State<ProjectSliderForDesignTwo> {
  final PageController _pageController = PageController(viewportFraction: 0.9);
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
        bool isDesktop = constraints.maxWidth > 800; // Detect PC
        return Column(
          children: [
            SizedBox(
              height: isDesktop ? 600 : 450, // Increased height for PC
              child: isDesktop
                  ? GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.75, // Adjust the card aspect ratio
                ),
                itemCount: widget.projects.length,
                itemBuilder: (context, index) {
                  return _buildProjectCard(index, isDesktop);
                },
              )
                  : PageView.builder(
                controller: _pageController,
                itemCount: widget.projects.length,
                physics: BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  double scale = (index == currentPage.round()) ? 1.0 : 0.8;
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
            if (!isDesktop) // Show dots only on mobile
              SizedBox(height: 16),
            if (!isDesktop)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.projects.length, (index) {
                  bool isActive = index == currentPage.round();
                  return Container(
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
        );
      },
    );
  }

  Widget _buildProjectCard(int index, bool isDesktop) {
    return Card(
      color: Color(0xff1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Project image
              if (widget.projects[index]["image"] != null &&
                  widget.projects[index]["image"].isNotEmpty)
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => FullScreenImageView(
                        imageUrl: widget.projects[index]["image"],
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      widget.projects[index]["image"],
                      width: double.infinity,
                      height: isDesktop ? 300 : 200, // Larger image for PC
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.image_not_supported,
                        size: 50,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              SizedBox(height: 8),
              // Project title
              Text(
                widget.projects[index]["title"] ?? "No Title",
                style: GoogleFonts.blinker(
                  fontSize: 30,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              // Project description
              Text(
                widget.projects[index]["description"] ?? "No Description",
                style: GoogleFonts.blinker(
                  fontSize: 15,
                  color: Colors.white60,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              // Project tech stack
              Text(
                widget.projects[index]["techstack"] ?? "No techstack",
                style: GoogleFonts.blinker(
                  fontSize: 20,
                  color: Colors.white60,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 10),
              // Action buttons (GitHub & YouTube)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      final url = widget.projects[index]["projectgithublink"] ?? "";
                      _launchURL(url);
                    },
                    icon: Icon(Icons.code, color: Colors.white),
                    label: Text(
                      "GitHub",
                      style: GoogleFonts.blinker(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      final url = widget.projects[index]["projectyoutubelink"] ?? "";
                      _launchURL(url);
                    },
                    icon: Icon(Icons.video_library, color: Colors.white),
                    label: Text(
                      "YouTube",
                      style: GoogleFonts.blinker(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
