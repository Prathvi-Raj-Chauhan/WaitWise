import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wait_wise/provider/provider.dart';

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
          backgroundColor: const Color(0xFFE3E5E8),
          appBar: AppBar(
            backgroundColor: const Color(0xFFF5F6F7),
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            shadowColor: Colors.black.withOpacity(0.08),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF888888), size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: Row(
              children: [
                const Icon(Icons.local_hospital_outlined, color: Color(0xFFE8400A), size: 16),
                const SizedBox(width: 8),
                Text(
                  'RECEPTIONIST',
                  style: GoogleFonts.jetBrainsMono(
                    color: const Color(0xFF1A1A1A),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
            actions: [
              // Clinic ID chip
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: widget.clinicId));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'CLINIC ID COPIED',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                      duration: const Duration(seconds: 1),
                      backgroundColor: const Color(0xFFE8400A),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECEDEF),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFD6D8DB), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.clinicId,
                        style: GoogleFonts.jetBrainsMono(
                          color: const Color(0xFF1A1A1A),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Icon(Icons.copy_rounded, color: Color(0xFF888888), size: 12),
                    ],
                  ),
                ),
              ),
              // Live status
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: queue.connected ? const Color(0xFFE8400A) : const Color(0xFFBBBBBB),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      queue.connected ? 'LIVE' : 'OFFLINE',
                      style: GoogleFonts.jetBrainsMono(
                        color: queue.connected ? const Color(0xFFE8400A) : const Color(0xFFBBBBBB),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
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

                // ── Now Serving card ──
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F6F7),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFD6D8DB), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        offset: const Offset(0, 4),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'NOW SERVING',
                              style: GoogleFonts.jetBrainsMono(
                                color: const Color(0xFFE8400A),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.8,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              queue.currentToken != null
                                  ? '#${queue.currentToken!.number}'
                                  : '—',
                              style: GoogleFonts.jetBrainsMono(
                                color: const Color(0xFF1A1A1A),
                                fontSize: 52,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -2,
                                height: 1,
                              ),
                            ),
                            if (queue.currentToken != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                queue.currentToken!.name,
                                style: GoogleFonts.jetBrainsMono(
                                  color: const Color(0xFF888888),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      // Next button
                      GestureDetector(
                        onTap: queue.connected
                            ? () => ref.read(queueProvider.notifier).callNext()
                            : null,
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: queue.connected
                                ? const Color(0xFFE8400A)
                                : const Color(0xFFD6D8DB),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: queue.connected
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFFE8400A).withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Icon(
                            Icons.skip_next_rounded,
                            color: queue.connected ? Colors.white : const Color(0xFF888888),
                            size: 28,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Add patient field ──
                Row(
                  children: [
                    Expanded(
                      child: _buildField(
                        controller: _nameController,
                        hint: 'patient name',
                        icon: Icons.person_outline_rounded,
                        onSubmitted: (_) => _addPatient(ref),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => _addPatient(ref),
                      child: Container(
                        width: 52,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8400A),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ── Queue header ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'WAITING QUEUE',
                      style: GoogleFonts.jetBrainsMono(
                        color: const Color(0xFF1A1A1A),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.8,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECEDEF),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFD6D8DB), width: 1),
                      ),
                      child: Text(
                        '${queue.waitingCount} patients',
                        style: GoogleFonts.jetBrainsMono(
                          color: const Color(0xFF555555),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // ── Queue list ──
                Expanded(
                  child: queue.waiting.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFECEDEF),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFFD6D8DB), width: 1),
                                ),
                                child: const Icon(
                                  Icons.check_circle_outline_rounded,
                                  color: Color(0xFFE8400A),
                                  size: 26,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'Queue is empty',
                                style: GoogleFonts.jetBrainsMono(
                                  color: const Color(0xFF1A1A1A),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Add a patient above to get started.',
                                style: GoogleFonts.jetBrainsMono(
                                  color: const Color(0xFF888888),
                                  fontSize: 11,
                                ),
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F6F7),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isNext
                                      ? const Color(0xFFE8400A).withOpacity(0.4)
                                      : const Color(0xFFD6D8DB),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    offset: const Offset(0, 2),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // Token number box
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: isNext
                                          ? const Color(0xFFE8400A).withOpacity(0.1)
                                          : const Color(0xFFECEDEF),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isNext
                                            ? const Color(0xFFE8400A).withOpacity(0.3)
                                            : const Color(0xFFD6D8DB),
                                        width: 1,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${t.number}',
                                        style: GoogleFonts.jetBrainsMono(
                                          color: isNext
                                              ? const Color(0xFFE8400A)
                                              : const Color(0xFF555555),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          t.name,
                                          style: GoogleFonts.jetBrainsMono(
                                            color: const Color(0xFF1A1A1A),
                                            fontSize: 13,
                                            fontWeight: isNext
                                                ? FontWeight.w600
                                                : FontWeight.w400,
                                          ),
                                        ),
                                        if (isNext)
                                          Text(
                                            'UP NEXT',
                                            style: GoogleFonts.jetBrainsMono(
                                              color: const Color(0xFFE8400A),
                                              fontSize: 9,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 1.0,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  // Wait time
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFECEDEF),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          color: const Color(0xFFD6D8DB), width: 1),
                                    ),
                                    child: Text(
                                      '~${t.estWaitMins} min',
                                      style: GoogleFonts.jetBrainsMono(
                                        color: const Color(0xFF888888),
                                        fontSize: 10,
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

                // ── Bottom log strip ──
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECEDEF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFD6D8DB), width: 1),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: queue.connected
                              ? const Color(0xFFE8400A)
                              : const Color(0xFFBBBBBB),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        queue.connected
                            ? 'SYNC_ACTIVE // NODE_01 // REGION_IN'
                            : 'SYNC_INACTIVE // RECONNECTING...',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 9,
                          color: const Color(0xFF888888),
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    ValueChanged<String>? onSubmitted,
  }) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFECEDEF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFD6D8DB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
          const BoxShadow(
            color: Colors.white,
            offset: Offset(0, -1),
            blurRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(icon, size: 16, color: const Color(0xFF888888)),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onSubmitted: onSubmitted,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 12,
                color: const Color(0xFF1A1A1A),
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: GoogleFonts.jetBrainsMono(
                  fontSize: 12,
                  color: const Color(0xFFAAAAAA),
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}