/// Domain entity representing a customer review and rating comment on a product.
class Comment {
  const Comment({
    required this.id,
    required this.userId,
    required this.productId,
    required this.targetProfileId,
    required this.content,
    required this.rating,
    required this.createdAt,
    required this.authorName,
  });

  final int id;
  final int userId;
  final int productId;
  final int targetProfileId;
  final String content;
  final int rating;
  final DateTime createdAt;
  final String authorName;

  Comment copyWith({
    int? id,
    int? userId,
    int? productId,
    int? targetProfileId,
    String? content,
    int? rating,
    DateTime? createdAt,
    String? authorName,
  }) {
    return Comment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      targetProfileId: targetProfileId ?? this.targetProfileId,
      content: content ?? this.content,
      rating: rating ?? this.rating,
      createdAt: createdAt ?? this.createdAt,
      authorName: authorName ?? this.authorName,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Comment &&
        other.id == id &&
        other.userId == userId &&
        other.productId == productId &&
        other.targetProfileId == targetProfileId &&
        other.content == content &&
        other.rating == rating &&
        other.createdAt == createdAt &&
        other.authorName == authorName;
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    productId,
    targetProfileId,
    content,
    rating,
    createdAt,
    authorName,
  );

  @override
  String toString() {
    return 'Comment(id: $id, userId: $userId, productId: $productId, rating: $rating, author: $authorName, content: $content)';
  }
}
