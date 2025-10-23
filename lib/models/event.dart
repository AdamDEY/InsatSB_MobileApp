enum Chapter {
  cs('CS'),
  ras('RAS'),
  pesPels('PES/PELS'),
  ias('IAS'),
  sight('SIGHT'),
  wie('WIE');

  const Chapter(this.displayName);
  final String displayName;

  static Chapter fromString(String value) {
    switch (value.toLowerCase()) {
      case 'cs':
        return Chapter.cs;
      case 'ras':
        return Chapter.ras;
      case 'pes/pels':
      case 'pesxpels':
        return Chapter.pesPels;
      case 'ias':
        return Chapter.ias;
      case 'sight':
        return Chapter.sight;
      case 'wie':
        return Chapter.wie;
      default:
        throw ArgumentError('Invalid chapter: $value');
    }
  }
}

class Event {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;
  final String category; // Event type (Workshop, Seminar, etc.)
  final int attendeesNeeded; // Maximum capacity
  final int registrations; // Current registrations
  final String level;
  final Chapter chapter; // IEEE chapter (CS, RAS, etc.)
  final bool isFeatured;
  final bool isFavorite;
  final bool isRegistered;
  final String speakerFullName;
  final String aboutSpeaker;
  final String prerequisites;
  final String speakerLinkedIn;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.category,
    required this.attendeesNeeded,
    required this.registrations,
    required this.level,
    required this.chapter,
    required this.speakerFullName,
    required this.aboutSpeaker,
    required this.prerequisites,
    required this.speakerLinkedIn,
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
      attendeesNeeded: json['attendeesNeeded'] ?? 0,
      registrations: json['registrations'] ?? 0,
      level: json['level'] ?? '',
      chapter: Chapter.fromString(json['chapter'] ?? 'cs'),
      speakerFullName: json['speakerFullName'] ?? '',
      aboutSpeaker: json['aboutSpeaker'] ?? '',
      prerequisites: json['prerequisites'] ?? '',
      speakerLinkedIn: json['speakerLinkedIn'] ?? '',
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
      'attendeesNeeded': attendeesNeeded,
      'registrations': registrations,
      'level': level,
      'chapter': chapter.displayName,
      'speakerFullName': speakerFullName,
      'aboutSpeaker': aboutSpeaker,
      'prerequisites': prerequisites,
      'speakerLinkedIn': speakerLinkedIn,
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
    int? attendeesNeeded,
    int? registrations,
    String? level,
    Chapter? chapter,
    String? speakerFullName,
    String? aboutSpeaker,
    String? prerequisites,
    String? speakerLinkedIn,
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
      attendeesNeeded: attendeesNeeded ?? this.attendeesNeeded,
      registrations: registrations ?? this.registrations,
      level: level ?? this.level,
      chapter: chapter ?? this.chapter,
      speakerFullName: speakerFullName ?? this.speakerFullName,
      aboutSpeaker: aboutSpeaker ?? this.aboutSpeaker,
      prerequisites: prerequisites ?? this.prerequisites,
      speakerLinkedIn: speakerLinkedIn ?? this.speakerLinkedIn,
      isFeatured: isFeatured ?? this.isFeatured,
      isFavorite: isFavorite ?? this.isFavorite,
      isRegistered: isRegistered ?? this.isRegistered,
    );
  }
}
