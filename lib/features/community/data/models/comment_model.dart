import '../../domain/entities/comment.dart';

/// Data transfer model for [Comment] mapping JSON responses from
/// `GET /api/v1/products/{productId}/comments`, `POST /api/v1/comments` and `PUT /api/v1/comments/{id}`.
class CommentModel extends Comment {
  const CommentModel({
    required super.id,
    required super.userId,
    required super.productId,
    required super.targetProfileId,
    required super.content,
    required super.rating,
    required super.createdAt,
    required super.authorName,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    final rawCreatedAt = json['createdAt'];
    final parsedDate = switch (rawCreatedAt) {
      final String str => DateTime.tryParse(str) ?? DateTime.now(),
      final DateTime dt => dt,
      _ => DateTime.now(),
    };

    return CommentModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      productId: (json['productId'] as num?)?.toInt() ?? 0,
      targetProfileId: (json['targetProfileId'] as num?)?.toInt() ?? 0,
      content: (json['content'] as String?) ?? '',
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      createdAt: parsedDate,
      authorName: (json['authorName'] as String?) ?? 'Anónimo',
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'productId': productId,
      'targetProfileId': targetProfileId,
      'content': content,
      'rating': rating,
      'createdAt': createdAt.toIso8601String(),
      'authorName': authorName,
    };
  }

  factory CommentModel.fromEntity(Comment entity) {
    return CommentModel(
      id: entity.id,
      userId: entity.userId,
      productId: entity.productId,
      targetProfileId: entity.targetProfileId,
      content: entity.content,
      rating: entity.rating,
      createdAt: entity.createdAt,
      authorName: entity.authorName,
    );
  }
}
