import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AllReviewsPage extends StatefulWidget {
  final String shopEmail;
  final String shopName;

  const AllReviewsPage({
    Key? key,
    required this.shopEmail,
    required this.shopName,
  }) : super(key: key);

  @override
  State<AllReviewsPage> createState() => _AllReviewsPageState();
}

class _AllReviewsPageState extends State<AllReviewsPage> {
  int? selectedRating; // null means show all

  Widget _buildStars(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return Icon(Icons.star, color: Colors.amber, size: 18);
        } else if (index < rating && rating % 1 != 0) {
          return Icon(Icons.star_half, color: Colors.amber, size: 18);
        } else {
          return Icon(Icons.star_border, color: Colors.amber, size: 18);
        }
      }),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return "Just now";
    try {
      DateTime dateTime = DateTime.parse(timestamp.toString());
      Duration difference = DateTime.now().difference(dateTime);
      
      if (difference.inDays > 365) {
        return "${(difference.inDays / 365).floor()} year${(difference.inDays / 365).floor() > 1 ? 's' : ''} ago";
      } else if (difference.inDays > 30) {
        return "${(difference.inDays / 30).floor()} month${(difference.inDays / 30).floor() > 1 ? 's' : ''} ago";
      } else if (difference.inDays > 0) {
        return "${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago";
      } else if (difference.inHours > 0) {
        return "${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago";
      } else if (difference.inMinutes > 0) {
        return "${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago";
      } else {
        return "Just now";
      }
    } catch (e) {
      return "Recently";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          "All Reviews",
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF667eea),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                    label: Text(
                      "All",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: selectedRating == null ? Colors.white : Colors.grey[700],
                      ),
                    ),
                    selected: selectedRating == null,
                    onSelected: (selected) {
                      setState(() {
                        selectedRating = null;
                      });
                    },
                    backgroundColor: Colors.grey[100],
                    selectedColor: Color(0xFF667eea),
                    checkmarkColor: Colors.white,
                    side: BorderSide(
                      color: selectedRating == null ? Color(0xFF667eea) : Colors.grey[300]!,
                      width: 0,
                    ),
                  ),
                  SizedBox(width: 8),
                  ...List.generate(5, (index) {
                    int rating = 5 - index; // 5, 4, 3, 2, 1
                    return Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "$rating",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: selectedRating == rating ? Colors.white : Colors.grey[700],
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.star,
                              size: 16,
                              color: selectedRating == rating ? Colors.white : Colors.amber,
                            ),
                          ],
                        ),
                        selected: selectedRating == rating,
                        onSelected: (selected) {
                          setState(() {
                            selectedRating = selected ? rating : null;
                          });
                        },
                        backgroundColor: Colors.grey[100],
                        selectedColor: Color(0xFF667eea),
                        checkmarkColor: Colors.white,
                        side: BorderSide(
                          color: selectedRating == rating ? Color(0xFF667eea) : Colors.grey[300]!,
                          width: 0,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          // Reviews List
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: FirebaseDatabase.instance
                  .ref("reviews/${widget.shopEmail.replaceAll('.', '_')}")
                  .onValue,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Error loading reviews",
                      style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.reviews_outlined, size: 64, color: Colors.grey[300]),
                        SizedBox(height: 16),
                        Text(
                          "No reviews yet",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                Map<dynamic, dynamic> reviewsMap = snapshot.data!.snapshot.value as Map;
                List<MapEntry> reviewsList = reviewsMap.entries.toList()
                  ..sort((a, b) {
                    // Sort by rating (descending), then by timestamp (newest first)
                    int ratingCompare = (b.value["rating"] ?? 0).compareTo(a.value["rating"] ?? 0);
                    if (ratingCompare != 0) return ratingCompare;
                    return (b.value["timestamp"] ?? 0).compareTo(a.value["timestamp"] ?? 0);
                  });

                // Filter by selected rating
                if (selectedRating != null) {
                  reviewsList = reviewsList.where((entry) {
                    return (entry.value["rating"] ?? 0).round() == selectedRating;
                  }).toList();
                }

                if (reviewsList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.filter_list_off, size: 64, color: Colors.grey[300]),
                        SizedBox(height: 16),
                        Text(
                          "No reviews with $selectedRating stars",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: reviewsList.length,
                  itemBuilder: (context, index) {
                    var review = reviewsList[index].value;
                    return Container(
                      margin: EdgeInsets.only(bottom: 16),
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Color(0xFF667eea).withOpacity(0.2),
                                child: Text(
                                  (review["userName"]?.toString().isNotEmpty == true
                                      ? review["userName"][0]
                                      : "U").toUpperCase(),
                                  style: GoogleFonts.poppins(
                                    color: Color(0xFF667eea),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      review["userName"] ?? "Anonymous",
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      _formatTimestamp(review["timestamp"]),
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _buildStars(review["rating"]?.toDouble() ?? 0.0),
                            ],
                          ),
                          SizedBox(height: 12),
                          Text(
                            review["review"] ?? "",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[700],
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
