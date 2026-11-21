class UserSession {
  final String studentName;
  final String initials;
  final String email;
  final String? moodleSessionCookie;
  final bool isLoggedIn;
  final DateTime? lastSync;

  UserSession({
    this.studentName = 'Hetsel',
    this.initials = 'HE',
    this.email = 'hetsel@itla.edu.do',
    this.moodleSessionCookie,
    this.isLoggedIn = false,
    this.lastSync,
  });

  UserSession copyWith({
    String? studentName,
    String? initials,
    String? email,
    String? moodleSessionCookie,
    bool? isLoggedIn,
    DateTime? lastSync,
  }) {
    return UserSession(
      studentName: studentName ?? this.studentName,
      initials: initials ?? this.initials,
      email: email ?? this.email,
      moodleSessionCookie: moodleSessionCookie ?? this.moodleSessionCookie,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      lastSync: lastSync ?? this.lastSync,
    );
  }

  Map<String, dynamic> toJson() => {
        'studentName': studentName,
        'initials': initials,
        'email': email,
        'moodleSessionCookie': moodleSessionCookie,
        'isLoggedIn': isLoggedIn,
        'lastSync': lastSync?.toIso8601String(),
      };

  factory UserSession.fromJson(Map<String, dynamic> json) => UserSession(
        studentName: json['studentName'] ?? 'Hetsel',
        initials: json['initials'] ?? 'HE',
        email: json['email'] ?? 'hetsel@itla.edu.do',
        moodleSessionCookie: json['moodleSessionCookie'],
        isLoggedIn: json['isLoggedIn'] ?? false,
        lastSync: json['lastSync'] != null ? DateTime.tryParse(json['lastSync']) : null,
      );
}
