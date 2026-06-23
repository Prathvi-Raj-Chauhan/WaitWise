import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wait_wise/provider/provider.dart';

class tv extends StatefulWidget {
  const tv({super.key});

  @override
  State<tv> createState() => _tvState();
}

class _tvState extends State<tv> {
  @override
  Widget build(BuildContext context) {
    return const TvScreen();
  }
}

class TvScreen extends ConsumerStatefulWidget {
  const TvScreen({super.key});

  @override
  ConsumerState<TvScreen> createState() => _TvScreenState();
}

class _TvScreenState extends ConsumerState<TvScreen> with TickerProviderStateMixin {
  late AnimationController _heroController;
  late Animation<double> _heroScale;
  late Animation<double> _heroFade;

  String? _prevTokenNumber;

  @override
  void initState() {
    super.initState();
    _heroController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _heroScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _heroController, curve: Curves.elasticOut),
    );
    _heroFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _heroController, curve: Curves.easeOut),
    );
    _heroController.forward();
  }

  @override
  void dispose() {
    _heroController.dispose();
    super.dispose();
  }

  void _triggerHeroAnimation() {
    _heroController.reset();
    _heroController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final queue = ref.watch(queueProvider);
    final hasToken = queue.currentToken != null;
    final currentNumber = queue.currentToken?.number.toString();

    if (currentNumber != _prevTokenNumber) {
      _prevTokenNumber = currentNumber;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _triggerHeroAnimation();
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFF060D1A),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFF14B8A6).withOpacity(0.15),
                          borderRadius: const BorderRadius.all(Radius.circular(8)),
                        ),
                        child: const Icon(
                          Icons.access_time_rounded,
                          color: Color(0xFF14B8A6),
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'WaitWise',
                        style: TextStyle(
                          color: Color(0x99F8FAFC),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const _LiveBadge(),
                ],
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'NOW SERVING',
                    style: TextStyle(
                      color: Color(0xFF14B8A6),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ScaleTransition(
                    scale: _heroScale,
                    child: FadeTransition(
                      opacity: _heroFade,
                      child: Text(
                        hasToken ? '#${queue.currentToken!.number}' : '—',
                        style: const TextStyle(
                          color: Color(0xFFF8FAFC),
                          fontSize: 150,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -8,
                          height: 0.95,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      hasToken ? queue.currentToken!.name : 'No one is being served',
                      key: ValueKey(queue.currentToken?.name),
                      style: TextStyle(
                        color: hasToken ? const Color(0xCCF8FAFC) : const Color(0x44F8FAFC),
                        fontSize: 26,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _StatBox(
                        value: '${queue.waitingCount}',
                        label: 'Waiting',
                        color: const Color(0xFFF59E0B),
                      ),
                      Container(
                        width: 1,
                        height: 50,
                        color: const Color(0xFF1E293B),
                        margin: const EdgeInsets.symmetric(horizontal: 36),
                      ),
                      _StatBox(
                        value: queue.waiting.isNotEmpty
                            ? '${queue.waiting.first.estWaitMins} min'
                            : '0 min',
                        label: 'Est. Next Wait',
                        color: const Color(0xFF14B8A6),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (queue.waiting.isNotEmpty || queue.currentToken != null)
              _TokenQueue(
                currentToken: queue.currentToken,
                waiting: queue.waiting,
              ),
          ],
        ),
      ),
    );
  }
}

class _TokenQueue extends StatelessWidget {
  final dynamic currentToken;
  final List<dynamic> waiting;

  const _TokenQueue({required this.currentToken, required this.waiting});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
      decoration: const BoxDecoration(
        color: Color(0xFF0A1628),
        border: Border(top: BorderSide(color: Color(0xFF1E293B), width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'QUEUE',
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                if (currentToken != null)
                  _TokenCard(
                    number: currentToken!.number,
                    name: currentToken!.name,
                    isCurrent: true,
                  ),
                if (currentToken != null && waiting.isNotEmpty)
                  const SizedBox(width: 10),
                ...waiting.take(6).toList().asMap().entries.map((entry) {
                  return Padding(
                    padding: EdgeInsets.only(right: entry.key < waiting.take(6).length - 1 ? 10 : 0),
                    child: _TokenCard(
                      number: entry.value.number,
                      name: entry.value.name,
                      isCurrent: false,
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TokenCard extends StatelessWidget {
  final int number;
  final String name;
  final bool isCurrent;

  const _TokenCard({
    required this.number,
    required this.name,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      width: 110,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: isCurrent ? const Color(0xFF14B8A6).withOpacity(0.15) : const Color(0xFF1E293B),
        borderRadius: const BorderRadius.all(Radius.circular(14)),
        border: Border.all(
          color: isCurrent ? const Color(0xFF14B8A6).withOpacity(0.5) : const Color(0xFF334155),
          width: isCurrent ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isCurrent)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF14B8A6).withOpacity(0.2),
                borderRadius: const BorderRadius.all(Radius.circular(4)),
              ),
              child: const Text(
                'NOW',
                style: TextStyle(
                  color: Color(0xFF14B8A6),
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ),
          Text(
            '#$number',
            style: TextStyle(
              color: isCurrent ? const Color(0xFF14B8A6) : const Color(0xCCF8FAFC),
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 11,
              fontWeight: FontWeight.w400,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatBox({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 48,
            fontWeight: FontWeight.w700,
            letterSpacing: -1.5,
            height: 1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 13,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _LiveBadge extends StatefulWidget {
  const _LiveBadge();

  @override
  State<_LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<_LiveBadge> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _anim = Tween(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF14B8A6).withOpacity(0.12),
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        border: Border.all(color: const Color(0xFF14B8A6).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FadeTransition(
            opacity: _anim,
            child: Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: Color(0xFF14B8A6),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            'LIVE',
            style: TextStyle(
              color: Color(0xFF14B8A6),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}