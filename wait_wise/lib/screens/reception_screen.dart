import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wait_wise/provider/provider.dart';

class WW {
  static const bg = Color(0xFF0F172A);
  static const surface = Color(0xFF1E293B);
  static const surfaceHigh = Color(0xFF334155);
  static const teal = Color(0xFF14B8A6);
  static const amber = Color(0xFFF59E0B);
  static const red = Color(0xFFEF4444);
  static const textPrimary = Color(0xFFF8FAFC);
  static const textSecondary = Color(0xFF94A3B8);

  static const r12 = BorderRadius.all(Radius.circular(12));
  static const r20 = BorderRadius.all(Radius.circular(20));

  static InputDecoration inputDeco(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
      floatingLabelStyle: const TextStyle(color: Color(0xFF14B8A6), fontSize: 12),
      prefixIcon: icon != null ? Icon(icon, color: const Color(0xFF94A3B8), size: 20) : null,
      filled: true,
      fillColor: const Color(0xFF1E293B),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: r12,
        borderSide: const BorderSide(color: Color(0xFF334155)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: r12,
        borderSide: const BorderSide(color: Color(0xFF334155)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: r12,
        borderSide: const BorderSide(color: Color(0xFF14B8A6), width: 1.5),
      ),
    );
  }
}

class ReceptionPage extends StatefulWidget {
  final String clinicId;
  const ReceptionPage({super.key, required this.clinicId});

  @override
  State<ReceptionPage> createState() => _ReceptionPageState();
}

class _ReceptionPageState extends State<ReceptionPage> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _addPatient(WidgetRef ref) {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    ref.read(queueProvider.notifier).addPatient(name);
    _nameController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final queue = ref.watch(queueProvider);

        return Scaffold(
          backgroundColor: WW.bg,
          appBar: AppBar(
            backgroundColor: WW.surface,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: WW.textSecondary),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Row(
              children: [
                Icon(Icons.local_hospital_outlined, color: WW.teal, size: 18),
                SizedBox(width: 8),
                Text(
                  'Receptionist',
                  style: TextStyle(
                    color: WW.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            actions: [
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: widget.clinicId));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Clinic ID copied'),
                      duration: Duration(seconds: 1),
                      backgroundColor: WW.teal,
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: WW.amber.withOpacity(0.15),
                    borderRadius: WW.r12,
                    border: Border.all(color: WW.amber.withOpacity(0.3), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.clinicId,
                        style: const TextStyle(
                          color: WW.amber,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.copy_rounded, color: WW.amber, size: 12),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: queue.connected ? WW.teal : WW.red,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (queue.connected ? WW.teal : WW.red).withOpacity(0.5),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      queue.connected ? 'Live' : 'Offline',
                      style: TextStyle(
                        color: queue.connected ? WW.teal : WW.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        WW.teal.withOpacity(0.15),
                        WW.teal.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: WW.r20,
                    border: Border.all(color: WW.teal.withOpacity(0.25), width: 1),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'NOW SERVING',
                              style: TextStyle(
                                color: WW.teal,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.4,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              queue.currentToken != null ? '#${queue.currentToken!.number}' : '—',
                              style: const TextStyle(
                                color: WW.textPrimary,
                                fontSize: 52,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -2,
                                height: 1,
                              ),
                            ),
                            if (queue.currentToken != null)
                              Text(
                                queue.currentToken!.name,
                                style: const TextStyle(color: WW.textSecondary, fontSize: 14),
                              ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: queue.connected
                            ? () => ref.read(queueProvider.notifier).callNext()
                            : null,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: queue.connected ? WW.teal : WW.surfaceHigh,
                            shape: BoxShape.circle,
                            boxShadow: queue.connected
                                ? [
                                    BoxShadow(
                                      color: WW.teal.withOpacity(0.4),
                                      blurRadius: 16,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Icon(
                            Icons.skip_next_rounded,
                            color: queue.connected ? WW.bg : WW.textSecondary,
                            size: 30,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nameController,
                        style: const TextStyle(color: WW.textPrimary, fontSize: 14),
                        decoration: WW.inputDeco('Patient name', icon: Icons.person_outline),
                        onSubmitted: (_) => _addPatient(ref),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () => _addPatient(ref),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: WW.teal,
                        foregroundColor: WW.bg,
                        minimumSize: const Size(54, 54),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: WW.r12),
                        elevation: 0,
                      ),
                      child: const Icon(Icons.add_rounded, size: 22),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Waiting Queue',
                      style: TextStyle(
                        color: WW.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: WW.teal.withOpacity(0.15),
                        borderRadius: WW.r12,
                      ),
                      child: Text(
                        '${queue.waitingCount} patients',
                        style: const TextStyle(
                          color: WW.teal,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: queue.waiting.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: const BoxDecoration(
                                  color: WW.surface,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_circle_outline_rounded,
                                  color: WW.teal,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Queue is empty',
                                style: TextStyle(
                                  color: WW.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Add a patient above to get started.',
                                style: TextStyle(color: WW.textSecondary, fontSize: 13),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          itemCount: queue.waiting.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (_, i) {
                            final t = queue.waiting[i];
                            final isNext = i == 0;
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: isNext ? WW.teal.withOpacity(0.08) : WW.surface,
                                borderRadius: WW.r12,
                                border: Border.all(
                                  color: isNext ? WW.teal.withOpacity(0.3) : WW.surfaceHigh,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: isNext
                                          ? WW.teal.withOpacity(0.2)
                                          : WW.surfaceHigh.withOpacity(0.5),
                                      borderRadius: WW.r12,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${t.number}',
                                        style: TextStyle(
                                          color: isNext ? WW.teal : WW.textSecondary,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          t.name,
                                          style: TextStyle(
                                            color: isNext ? WW.textPrimary : WW.textSecondary,
                                            fontSize: 14,
                                            fontWeight: isNext ? FontWeight.w600 : FontWeight.w400,
                                          ),
                                        ),
                                        if (isNext)
                                          const Text(
                                            'Up next',
                                            style: TextStyle(color: WW.teal, fontSize: 11),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: WW.surfaceHigh.withOpacity(0.5),
                                      borderRadius: WW.r12,
                                    ),
                                    child: Text(
                                      '~${t.estWaitMins} min',
                                      style: const TextStyle(
                                        color: WW.textSecondary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}