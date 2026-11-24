import 'package:equatable/equatable.dart';

/// A persisted notification addressed to the authenticated user's profile.
class ProductNotification extends Equatable {
  const ProductNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.isRead,
    required this.isAlert,
    this.createdAt,
  });

  final int id;
  final String title;
  final String message;
  final bool isRead;
  final bool isAlert;
  final DateTime? createdAt;

  ProductNotification copyWith({bool? isRead}) => ProductNotification(
    id: id, title: title, message: message,
    isRead: isRead ?? this.isRead,
    isAlert: isAlert, createdAt: createdAt,
  );

  @override
  List<Object?> get props => <Object?>[id, title, message, isRead, isAlert, createdAt];
}
