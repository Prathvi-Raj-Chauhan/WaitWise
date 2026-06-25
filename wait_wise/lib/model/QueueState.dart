class QueueState {
  final Token? currentToken;
  final List<Token> detailedPatients;
  final List<Waiting> waiting;
  final int waitingCount;
  final double avgConsultMins;
  final bool connected;

  QueueState({
    this.currentToken,
    this.waiting = const [],
    this.waitingCount = 0,
    this.avgConsultMins = 10,
    this.connected = false,
    this.detailedPatients = const [],
  });

  factory QueueState.empty() => QueueState();

  factory QueueState.fromJson(Map<String, dynamic> json) => QueueState(
        currentToken: json['current'] != null
            ? Token.fromJson(json['current'])
            : null,
        waiting: ((json['queue'] ?? []) as List) // takes selected data from queue to keep it lightweight
            .map((t) => Waiting.fromJson(t))
            .toList(),
        waitingCount: (json['queue'] as List?)?.length ?? 0,
        avgConsultMins:
            (json['avgConsultMins'] as num?)?.toDouble() ?? 10,
        detailedPatients: ((json['queue'] ?? []) as List) // takes all data from queue to make detailed patient
            .map((e) => Token.fromJson(e))
            .toList(),
        connected: true,
      );

  QueueState copyWith({
    Token? currentToken,
    List<Waiting>? waiting,
    int? waitingCount,
    double? avgConsultMins,
    bool? connected,
    List<Token>? detailedPatients,
  }) =>
      QueueState(
        currentToken: currentToken ?? this.currentToken,
        waiting: waiting ?? this.waiting,
        waitingCount: waitingCount ?? this.waitingCount,
        avgConsultMins: avgConsultMins ?? this.avgConsultMins,
        connected: connected ?? this.connected,
        detailedPatients: detailedPatients ?? this.detailedPatients,
      );

  QueueState optimisticCallNext() {
    if (waiting.isEmpty) return this;
    final next = waiting.first;
    final nextDetailed = detailedPatients.first;
    return copyWith(
      currentToken: nextDetailed,
      waiting: waiting.skip(1).toList(),
      detailedPatients: detailedPatients.skip(1).toList(),
      waitingCount: waitingCount - 1,
    );
  }

  QueueState rollback() => copyWith(connected: false);
}

class Token {
  final String id;
  final int number;
  final String name;
  final String? age;
  final String? gender;
  final String? bloodPressure;
  final String? weight;
  final String reason;
  final String? address;

  Token({
    required this.id,
    required this.number,
    required this.name,
    this.age,
    this.gender,
    this.bloodPressure,
    this.weight,
    this.reason = '',
    this.address,
  });

  factory Token.fromJson(Map<String, dynamic> json) => Token(
        id: json['id'] ?? '',
        number: json['token'],
        name: json['name'],
        age: json['age'],
        gender: json['gender'],
        bloodPressure: json['bloodPressure'],
        weight: json['weight'],
        reason: json['reason'] ?? '',
        address: json['address'],
      );
}

// Waiting is shown on the wait screen, no medical detail.
class Waiting {
  final String id;
  final int number;
  final String name;
  final int position;
  final int estWaitMins;

  Waiting({
    required this.id,
    required this.number,
    required this.name,
    required this.position,
    required this.estWaitMins,
  });

  factory Waiting.fromJson(Map<String, dynamic> json) => Waiting(
        id: json['id'] ?? '',
        number: json['token'],
        name: json['name'],
        position: json['position'] ?? 0,
        estWaitMins: json['estWaitMins'] ?? 0,
      );
}