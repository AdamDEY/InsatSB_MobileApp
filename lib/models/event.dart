class Event {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;
  final String category;
  final int attendees;
  final String level;
  final String imageUrl;
  final bool isFeatured;
  final bool isFavorite;
  final bool isRegistered;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.category,
    required this.attendees,
    required this.level,
    required this.imageUrl,
    this.isFeatured = false,
    this.isFavorite = false,
    this.isRegistered = false,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      startTime: DateTime.parse(json['startTime'] ?? DateTime.now().toIso8601String()),
      endTime: DateTime.parse(json['endTime'] ?? DateTime.now().toIso8601String()),
      category: json['category'] ?? '',
      attendees: json['attendees'] ?? 0,
      level: json['level'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      isFeatured: json['isFeatured'] ?? false,
      isFavorite: json['isFavorite'] ?? false,
      isRegistered: json['isRegistered'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'category': category,
      'attendees': attendees,
      'level': level,
      'imageUrl': imageUrl,
      'isFeatured': isFeatured,
      'isFavorite': isFavorite,
      'isRegistered': isRegistered,
    };
  }

  Event copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    DateTime? startTime,
    DateTime? endTime,
    String? category,
    int? attendees,
    String? level,
    String? imageUrl,
    bool? isFeatured,
    bool? isFavorite,
    bool? isRegistered,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      category: category ?? this.category,
      attendees: attendees ?? this.attendees,
      level: level ?? this.level,
      imageUrl: imageUrl ?? this.imageUrl,
      isFeatured: isFeatured ?? this.isFeatured,
      isFavorite: isFavorite ?? this.isFavorite,
      isRegistered: isRegistered ?? this.isRegistered,
    );
  }
}
