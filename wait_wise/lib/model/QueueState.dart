class QueueState{
  final Token? currentToken;
  final List<Waiting> waiting;
  final int waitingCount;
  final double avgConsultMins;
  final bool connected;

  QueueState({this.currentToken, this.waiting = const [], this.waitingCount = 0, this.avgConsultMins = 10, this.connected = false});

  factory QueueState.empty() => QueueState();

  factory QueueState.fromJson(Map<String, dynamic> json) => QueueState(
    currentToken: json['current'] != null ? Token.fromJson(json['current']) : null,
    waiting: ((json['queue'] ?? []) as List).map((t) => Waiting.fromJson(t)).toList(),
    waitingCount: (json['queue'] as List?)?.length ?? 0,
    avgConsultMins: (json['avgConsultMins'] as num?)?.toDouble() ?? 10,
    connected: true,
  );
  QueueState copyWith({Token? currentToken, List<Waiting>? waiting, int? waitingCount, double? avgConsultMins, bool? connected}) => QueueState(
    currentToken: currentToken ?? this.currentToken,
    waiting: waiting ?? this.waiting,
    waitingCount: waitingCount ?? this.waitingCount,
    avgConsultMins: avgConsultMins ?? this.avgConsultMins,
    connected: connected ?? this.connected,
  );
  QueueState optimisticCallNext() {
    if (waiting.isEmpty) return this;
    final next = waiting.first;
    return copyWith(
      currentToken: Token(id: next.id, number: next.number, name: next.name),
      waiting: waiting.skip(1).toList(),
      waitingCount: waitingCount - 1,
    );
  }
  QueueState rollback() => copyWith(connected: false);
}

class Token{
  final String id;
  final int number;
  final String name;

  Token({required this.id, required this.number, required this.name});

  factory Token.fromJson(Map<String, dynamic> json) => Token(
    id: json['id'] ?? "",
    number: json['token'],
    name: json['name'],
  );
}

class Waiting{
  final String id;
  final int number;
  final String name;
  final int position;
  final int estWaitMins;

  Waiting({required this.id, required this.number, required this.name, required this.position, required this.estWaitMins});

  factory Waiting.fromJson(Map<String, dynamic> json) => Waiting(
    id: json['id'] ?? "",
    number: json['token'], // same here
    name: json['name'],
    position: json['position'] ?? 0,
    estWaitMins: json['estWaitMins'] ?? 0,
  );
}