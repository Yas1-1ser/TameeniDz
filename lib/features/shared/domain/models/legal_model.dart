class LegalModel {
  final String id;
  final String title;
  final String content;
  final String iconName;
  final int displayOrder;

  LegalModel({
    required this.id,
    required this.title,
    required this.content,
    required this.iconName,
    required this.displayOrder,
  });

  factory LegalModel.fromJson(Map<String, dynamic> json) {
    return LegalModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      iconName: json['icon_name'] ?? 'gavel',
      displayOrder: json['display_order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'icon_name': iconName,
      'display_order': displayOrder,
    };
  }
}
