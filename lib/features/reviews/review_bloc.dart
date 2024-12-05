import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oezbooking/features/events/data/model/event.dart';
import 'package:oezbooking/features/reviews/comment.dart';

class CommentEntity {
  UserModel user;
  Comment comment;
  Event event;

  CommentEntity(this.user, this.comment, this.event);
}

abstract class ReviewEvent {}

class FetchCommentsByOrganizer extends ReviewEvent {
  final String organizerId;

  FetchCommentsByOrganizer(this.organizerId);
}

abstract class ReviewState {}

class ReviewInitial extends ReviewState {}

class ReviewLoading extends ReviewState {}

class ReviewLoaded extends ReviewState {
  final List<CommentEntity> comments;

  ReviewLoaded(this.comments);
}

class ReviewError extends ReviewState {
  final String message;

  ReviewError(this.message);
}

class ReviewBloc extends Cubit<ReviewState> {
  final FirebaseFirestore firestore;

  ReviewBloc(this.firestore) : super(ReviewInitial());

  // Xử lý sự kiện lấy comment theo organizerId
  Future<void> fetchCommentsByOrganizer(String organizerId) async {
    try {
      emit(ReviewLoading());

      // Truy vấn Firestore để lấy tất cả các event của organizer
      final eventSnapshot = await firestore
          .collection('events')
          .where('organizer', isEqualTo: organizerId)
          .get();

      // Danh sách để lưu các comment
      List<CommentEntity> allComments = [];

      // Lấy comment cho từng event
      for (var eventDoc in eventSnapshot.docs) {
        final eventData = eventDoc.data();
        final eventId = eventDoc.id;

        // Truy vấn comment của event đó
        final commentSnapshot = await firestore
            .collection('comments')
            .where('eventID', isEqualTo: eventId)
            .get();

        for (var commentDoc in commentSnapshot.docs) {
          final commentData = commentDoc.data();
          final userSnapshot = await firestore
              .collection('users')
              .doc(commentData['userID'])
              .get();
          final userData = userSnapshot.data();

          final comment = Comment.fromJson(commentData, userData!);
          final userModel = UserModel.fromJson(userData);
          final event = Event.fromJson(eventData);
          allComments.add(CommentEntity(userModel, comment, event));
        }
      }

      emit(ReviewLoaded(allComments));
    } catch (e) {
      emit(ReviewError('Failed to load comments: ${e.toString()}'));
    }
  }
}
