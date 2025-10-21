import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../pages/fullscreenimageview.dart';

class ProjectSliderForDesignOne extends StatefulWidget {
  final List<Map<String, dynamic>> projects;

  ProjectSliderForDesignOne({required this.projects});

  @override
  _ProjectSliderForDesignOneState createState() =>
      _ProjectSliderForDesignOneState();
}

class _ProjectSliderForDesignOneState extends State<ProjectSliderForDesignOne> {
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
                children: List.generate(widget.projects.length, (index) {
                  bool isActive = index == currentPage.round();
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: isActive ? Color(0xFF6366F1) : Color(0xFFCBD5E1),
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
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFFAFAFA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Color(0xFFE2E8F0),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF64748B).withOpacity(0.12),
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image with overlay
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
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          widget.projects[index]["image"],
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
              SizedBox(height: 16),
              // Project title
              Text(
                widget.projects[index]["title"] ?? "No Title",
                style: GoogleFonts.inter(
                  fontSize: 20,
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 8),
              // Description
              Text(
                widget.projects[index]["description"] ?? "No Description",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              Spacer(),
              // Product price
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "${widget.projects[index]["productprice"] ?? "No Price"}",
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: 16),
              // Buy Now button
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF6366F1).withOpacity(0.4),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      final url = widget.projects[index]["purchaseLink"] ?? "";
                      _launchURL(url);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_cart, color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Text(
                            "Buy Now",
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
