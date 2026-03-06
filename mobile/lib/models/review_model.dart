class ReviewModel {
  final String id;
  final String reviewerId;
  final String reviewerName;
  final String targetId;
  final String targetType;
  final double rating;
  final String? comment;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.reviewerId,
    required this.reviewerName,
    required this.targetId,
    required this.targetType,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'reviewerId': reviewerId, 'reviewerName': reviewerName,
    'targetId': targetId, 'targetType': targetType, 'rating': rating,
    'comment': comment, 'createdAt': createdAt.toIso8601String(),
  };

  factory ReviewModel.fromJson(Map<String, dynamic> json) => ReviewModel(
    id: json['id'], reviewerId: json['reviewerId'],
    reviewerName: json['reviewerName'], targetId: json['targetId'],
    targetType: json['targetType'],
    rating: (json['rating'] as num).toDouble(),
    comment: json['comment'],
    createdAt: DateTime.parse(json['createdAt']),
  );
}
