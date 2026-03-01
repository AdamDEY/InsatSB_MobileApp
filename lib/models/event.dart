enum Chapter {
  cs('CS'),
  ras('RAS'),
  pesPels('PES/PELS'),
  ias('IAS'),
  sight('SIGHT'),
  wie('WIE'),
  embs('EMBS');

  const Chapter(this.displayName);
  final String displayName;

  /// Parse a chapter string from the API. Returns null if the value is
  /// empty, 'null', or not recognised — callers should handle the null case.
  static Chapter? tryFromString(String? value) {
    if (value == null || value.isEmpty || value == 'null') return null;
    switch (value.toLowerCase()) {
      case 'cs':
        return Chapter.cs;
      case 'ras':
        return Chapter.ras;
      case 'pes/pels':
      case 'pespels':
      case 'pes_pels':
        return Chapter.pesPels;
      case 'ias':
        return Chapter.ias;
      case 'sight':
        return Chapter.sight;
      case 'wie':
        return Chapter.wie;
      case 'embs':
        return Chapter.embs;
      default:
        return null;
    }
  }

  static Chapter fromString(String value) {
    return tryFromString(value) ?? Chapter.cs;
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
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      date: _parseDateTime(json['date']),
      startTime: _parseDateTime(json['startTime']),
      endTime: _parseDateTime(json['endTime']),
      category: json['category']?.toString() ?? '',
      attendeesNeeded: _parseInt(json['attendeesNeeded']),
      registrations: _parseInt(json['registrations']),
      level: json['level']?.toString() ?? '',
      chapter: _parseChapter(json['chapter']),
      speakerFullName: json['speakerFullName']?.toString() ?? '',
      aboutSpeaker: json['aboutSpeaker']?.toString() ?? '',
      prerequisites: json['prerequisites']?.toString() ?? '',
      speakerLinkedIn:
          (json['speakerLinkedIn'] ?? json['speakerLinkedin'])?.toString() ??
          '',
      isFeatured: json['isFeatured'] == true,
      isFavorite: json['isFavorite'] == true,
      isRegistered: json['isRegistered'] == true,
    );
  }

  /// Parse chapter from API JSON value, logging a warning if it's null/missing.
  static Chapter _parseChapter(dynamic value) {
    final chapter = Chapter.tryFromString(value?.toString());
    if (chapter == null) {
      print(
        '⚠️ Event has null/invalid chapter value: $value — defaulting to CS',
      );
      return Chapter.cs;
    }
    return chapter;
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) {
      return DateTime.now();
    }
    if (value is DateTime) {
      return value;
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    if (value is double) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    }
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  static int _parseInt(dynamic value) {
    if (value == null) {
      return 0;
    }
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
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
