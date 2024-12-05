import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oezbooking/core/apps/app_colors.dart';
import 'package:oezbooking/features/login/presentation/bloc/login_bloc.dart';
import 'package:oezbooking/features/reviews/comment.dart';
import 'package:oezbooking/features/reviews/review_bloc.dart';

class OrganizerReviewsPage extends StatefulWidget {
  const OrganizerReviewsPage({Key? key}) : super(key: key);

  @override
  State<OrganizerReviewsPage> createState() => _OrganizerReviewsPageState();
}

class _OrganizerReviewsPageState extends State<OrganizerReviewsPage> {
  late LoginBloc loginBloc;

  @override
  void initState() {
    super.initState();
    loginBloc = BlocProvider.of<LoginBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReviewBloc(FirebaseFirestore.instance)
        ..fetchCommentsByOrganizer(loginBloc.organizer?.id ?? ""),
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          title: Text(
            '${loginBloc.organizer?.name ?? ""} - Event Reviews',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: AppColors.drawerColor,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: BlocBuilder<ReviewBloc, ReviewState>(
          builder: (context, state) {
            if (state is ReviewLoading) {
              return Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryColor,
                ),
              );
            }

            if (state is ReviewLoaded) {
              if (state.comments.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Icon(
                        Icons.reviews_outlined,
                        size: 80,
                        color: Colors.white38,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No reviews yet for ${loginBloc.organizer?.name ?? ""}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: state.comments.length,
                  itemBuilder: (context, index) {
                    final comment = state.comments.elementAt(index);
                    return _buildReviewCard(comment);
                  },
                );
              }
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildReviewCard(CommentEntity comment) {
    return Card(
      color: AppColors.drawerColor,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Name
            Text(
              comment.event.name,
              style: TextStyle(
                color: AppColors.primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Rating Stars
            Row(
              children: List.generate(
                5,
                (starIndex) => Icon(
                  starIndex < comment.comment.rating
                      ? Icons.star
                      : Icons.star_border,
                  color: AppColors.primaryColor,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Review Content
            Text(
              comment.comment.content,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),

            // Date and User Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  comment.user.fullName ?? "",
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _formatDate(comment.comment.createdAt),
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}

// Optional: Summary Widget for Organizer Reviews
class OrganizerReviewSummary extends StatelessWidget {
  final String organizerId;
  final String organizerName;

  const OrganizerReviewSummary({
    Key? key,
    required this.organizerId,
    required this.organizerName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.drawerColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('comments')
              .where('organizerID', isEqualTo: organizerId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator(
                color: AppColors.primaryColor,
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Text(
                'No reviews yet',
                style: TextStyle(color: Colors.white),
              );
            }

            // Calculate average rating
            double totalRating = 0;
            int reviewCount = snapshot.data!.docs.length;

            for (var doc in snapshot.data!.docs) {
              totalRating += (doc.data() as Map)['rating'] ?? 0.0;
            }

            double averageRating = totalRating / reviewCount;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$organizerName Reviews',
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      averageRating.toStringAsFixed(1),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          index < averageRating.round()
                              ? Icons.star
                              : Icons.star_border,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '$reviewCount Total Reviews',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
