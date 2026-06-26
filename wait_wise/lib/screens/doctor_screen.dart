import 'dart:async';
import 'dart:html' as html;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wait_wise/provider/provider.dart';
import 'package:wait_wise/widgets/LiveClock.dart';

class DoctorScreen extends StatefulWidget {
  const DoctorScreen({super.key});

  @override
  State<DoctorScreen> createState() => _DoctorScreenState();
}

class _DoctorScreenState extends State<DoctorScreen> {
  final now = DateTime.now();
  String currWeek = "";

  @override
  void initState() {
    super.initState();
    currWeek = _week(now.weekday);
  }

  String _week(int day) {
    const days = [
      '',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[day];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3E5E8),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          height: MediaQuery.of(context).size.height * 0.92,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F6F7),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                offset: const Offset(0, 12),
                blurRadius: 24,
                spreadRadius: 0,
              ),
            ],
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                // ── Top bar: date/time left, icons/weather right ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$currWeek ${now.day}/${now.month}/${now.year}',
                          style: GoogleFonts.jetBrainsMono(color: Colors.grey),
                        ),
                        const LiveClock(),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Icon(
                          Icons.medical_services_outlined,
                          color: Colors.grey,
                          size: 15,
                        ),
                        const SizedBox(height: 15,),
                        GestureDetector(
                          onTap: () {
                            context.go('/patient-history');
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                                const Color(0xFFE8400A),
                                  
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color:const Color(0xFFE8400A).withOpacity(0.3),
                                   
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 5,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color:  const Color.fromARGB(255, 255, 255, 255) ,
                            
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "Patient Record",
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 9,
                                    color: const Color.fromARGB(255, 255, 255, 255),
                            
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const _LiveWeather(),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // ── Middle row ──
                Expanded(
                  child: Consumer(
                    builder: (context, ref, _) {
                      final queue = ref.watch(queueProvider);
                      final current = queue.currentToken;
                      final next = queue.detailedPatients.isNotEmpty
                          ? queue.detailedPatients.first
                          : null;

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── LEFT: current patient panel ──
                          Expanded(
                            flex: 7,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: const Color(0xFFDCDDDE),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    spreadRadius: 4,
                                    blurRadius: 10,
                                    blurStyle: BlurStyle.inner,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Panel header
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      14,
                                      12,
                                      14,
                                      0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Q_CORE // CURRENT_PATIENT',
                                          style: GoogleFonts.jetBrainsMono(
                                            fontSize: 11,
                                            color: Colors.grey.shade600,
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                        // corner ticks like reference image
                                        Text(
                                          '⌐ ¬',
                                          style: GoogleFonts.jetBrainsMono(
                                            fontSize: 11,
                                            color: Colors.grey.shade400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 8),
                                  Divider(
                                    color: Colors.grey.shade400,
                                    height: 1,
                                    indent: 14,
                                    endIndent: 14,
                                  ),

                                  current == null
                                      ? Expanded(
                                          child: Center(
                                            child: Text(
                                              'NO_PATIENT // IDLE',
                                              style: GoogleFonts.jetBrainsMono(
                                                fontSize: 28,
                                                color: Colors.grey.shade400,
                                                letterSpacing: 4,
                                              ),
                                            ),
                                          ),
                                        )
                                      : Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(20),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // Token + name big display
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      '#${current.number}',
                                                      style:
                                                          GoogleFonts.jetBrainsMono(
                                                            fontSize: 72,
                                                            color: const Color(
                                                              0xFFE8400A,
                                                            ),
                                                            fontWeight:
                                                                FontWeight.w800,
                                                            letterSpacing: -2,
                                                            height: 1,
                                                          ),
                                                    ),
                                                    const SizedBox(width: 16),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            bottom: 10,
                                                          ),
                                                      child: Text(
                                                        current.name
                                                            .toUpperCase(),
                                                        style:
                                                            GoogleFonts.jetBrainsMono(
                                                              fontSize: 22,
                                                              color:
                                                                  const Color(
                                                                    0xFF1A1A1A,
                                                                  ),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              letterSpacing: 2,
                                                            ),
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                                const SizedBox(height: 24),

                                                // ── Detail grid ──
                                                Wrap(
                                                  spacing: 12,
                                                  runSpacing: 12,
                                                  children: [
                                                    if (current.age != null)
                                                      _detailChip(
                                                        'AGE',
                                                        '${current.age} yrs',
                                                        Icons.cake_outlined,
                                                      ),
                                                    if (current.gender !=
                                                            null &&
                                                        current
                                                            .gender!
                                                            .isNotEmpty)
                                                      _detailChip(
                                                        'GENDER',
                                                        current.gender!,
                                                        Icons
                                                            .person_outline_rounded,
                                                      ),
                                                    if (current.bloodPressure !=
                                                            null &&
                                                        current
                                                            .bloodPressure!
                                                            .isNotEmpty)
                                                      _detailChip(
                                                        'BP',
                                                        current.bloodPressure!,
                                                        Icons
                                                            .favorite_outline_rounded,
                                                      ),
                                                    if (current.weight != null)
                                                      _detailChip(
                                                        'WEIGHT',
                                                        '${current.weight} kg',
                                                        Icons
                                                            .monitor_weight_outlined,
                                                      ),
                                                    if (current.address !=
                                                            null &&
                                                        current
                                                            .address!
                                                            .isNotEmpty)
                                                      _detailChip(
                                                        'ADDR',
                                                        current.address!,
                                                        Icons
                                                            .location_on_outlined,
                                                      ),
                                                  ],
                                                ),

                                                const SizedBox(height: 20),

                                                // ── Reason box ──
                                                if (current
                                                    .reason
                                                    .isNotEmpty) ...[
                                                  Text(
                                                    'REASON_FOR_VISIT',
                                                    style:
                                                        GoogleFonts.jetBrainsMono(
                                                          fontSize: 9,
                                                          color: const Color(
                                                            0xFFE8400A,
                                                          ),
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          letterSpacing: 1.5,
                                                        ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Container(
                                                    width: double.infinity,
                                                    padding:
                                                        const EdgeInsets.all(
                                                          14,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                        0xFFF5F6F7,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                      border: Border.all(
                                                        color: const Color(
                                                          0xFFD6D8DB,
                                                        ),
                                                        width: 1,
                                                      ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black
                                                              .withOpacity(
                                                                0.04,
                                                              ),
                                                          offset: const Offset(
                                                            0,
                                                            2,
                                                          ),
                                                          blurRadius: 4,
                                                        ),
                                                        const BoxShadow(
                                                          color: Colors.white,
                                                          offset: Offset(0, -1),
                                                          blurRadius: 2,
                                                        ),
                                                      ],
                                                    ),
                                                    child: Text(
                                                      current.reason,
                                                      style:
                                                          GoogleFonts.jetBrainsMono(
                                                            fontSize: 13,
                                                            color: const Color(
                                                              0xFF1A1A1A,
                                                            ),
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            height: 1.5,
                                                          ),
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                        ),
                                ],
                              ),
                            ),
                          ),

                          const VerticalDivider(),

                          // ── RIGHT: operation logs style panel ──
                          Expanded(
                            flex: 3,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: const Color(0xFFFFFFFF),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 6,
                                  ),
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.8),
                                    offset: const Offset(-3, -3),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      14,
                                      12,
                                      14,
                                      0,
                                    ),
                                    child: Text(
                                      'OPERATION LOGS',
                                      style: GoogleFonts.jetBrainsMono(
                                        fontSize: 10,
                                        color: Colors.grey.shade500,
                                        letterSpacing: 1.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Divider(
                                    color: Colors.grey.shade200,
                                    height: 1,
                                    indent: 14,
                                    endIndent: 14,
                                  ),
                                  const SizedBox(height: 8),

                                  // Next patient preview
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                    ),
                                    child: Text(
                                      'UP_NEXT',
                                      style: GoogleFonts.jetBrainsMono(
                                        fontSize: 9,
                                        color: const Color(0xFFE8400A),
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                    ),
                                    child: next == null
                                        ? Text(
                                            'QUEUE_EMPTY',
                                            style: GoogleFonts.jetBrainsMono(
                                              fontSize: 11,
                                              color: Colors.grey.shade400,
                                              letterSpacing: 1,
                                            ),
                                          )
                                        : Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFECEDEF),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                color: const Color(0xFFD6D8DB),
                                                width: 1,
                                              ),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      '#${next.number}',
                                                      style:
                                                          GoogleFonts.jetBrainsMono(
                                                            fontSize: 18,
                                                            color: const Color(
                                                              0xFFE8400A,
                                                            ),
                                                            fontWeight:
                                                                FontWeight.w800,
                                                          ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: Text(
                                                        next.name,
                                                        style:
                                                            GoogleFonts.jetBrainsMono(
                                                              fontSize: 12,
                                                              color:
                                                                  const Color(
                                                                    0xFF1A1A1A,
                                                                  ),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                if (next.reason.isNotEmpty) ...[
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    next.reason,
                                                    style:
                                                        GoogleFonts.jetBrainsMono(
                                                          fontSize: 9,
                                                          color: Colors
                                                              .grey
                                                              .shade500,
                                                        ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                  ),

                                  const SizedBox(height: 14),
                                  Divider(
                                    color: Colors.grey.shade200,
                                    height: 1,
                                    indent: 14,
                                    endIndent: 14,
                                  ),
                                  const SizedBox(height: 8),

                                  // Queue log list
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                    ),
                                    child: Text(
                                      'QUEUE_LOG',
                                      style: GoogleFonts.jetBrainsMono(
                                        fontSize: 9,
                                        color: Colors.grey.shade500,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Expanded(
                                    child: queue.detailedPatients.isEmpty
                                        ? Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 14,
                                            ),
                                            child: Text(
                                              'NO PATIENTS IN QUEUE',
                                              style: GoogleFonts.jetBrainsMono(
                                                fontSize: 9,
                                                color: Colors.grey.shade400,
                                              ),
                                            ),
                                          )
                                        : ListView.builder(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 14,
                                            ),
                                            itemCount:
                                                queue.detailedPatients.length,
                                            itemBuilder: (_, i) {
                                              final p =
                                                  queue.detailedPatients[i];
                                              final isNext = i == 0;
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                  bottom: 6,
                                                ),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      '#${p.number}',
                                                      style:
                                                          GoogleFonts.jetBrainsMono(
                                                            fontSize: 10,
                                                            color: isNext
                                                                ? const Color(
                                                                    0xFFE8400A,
                                                                  )
                                                                : Colors
                                                                      .grey
                                                                      .shade500,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                          ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: Text(
                                                        p.name,
                                                        style:
                                                            GoogleFonts.jetBrainsMono(
                                                              fontSize: 10,
                                                              color:
                                                                  const Color(
                                                                    0xFF555555,
                                                                  ),
                                                              fontWeight: isNext
                                                                  ? FontWeight
                                                                        .w600
                                                                  : FontWeight
                                                                        .w400,
                                                            ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                  ),

                                  // Call Next button
                                  Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Consumer(
                                      builder: (context, ref, _) {
                                        final connected = ref
                                            .watch(queueProvider)
                                            .connected;
                                        return GestureDetector(
                                          onTap: connected
                                              ? () => ref
                                                    .read(
                                                      queueProvider.notifier,
                                                    )
                                                    .callNext()
                                              : null,
                                          child: Container(
                                            width: double.infinity,
                                            height: 44,
                                            decoration: BoxDecoration(
                                              color: connected
                                                  ? const Color(0xFFE8400A)
                                                  : const Color(0xFFD6D8DB),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Center(
                                              child: Text(
                                                'CALL_NEXT',
                                                style:
                                                    GoogleFonts.jetBrainsMono(
                                                      color: connected
                                                          ? Colors.white
                                                          : Colors.grey,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 11,
                                                      letterSpacing: 1.5,
                                                    ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                const SizedBox(height: 10),

                // ── Footer label ──
                Consumer(
                  builder: (context, ref, _) {
                    final queue = ref.watch(queueProvider);
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Wait_Wise // DOCTOR_VIEW',
                          style: GoogleFonts.jetBrainsMono(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                            fontSize: 11,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: queue.connected
                                ? const Color(0xFFE8400A).withOpacity(0.12)
                                : Colors.grey.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: queue.connected
                                  ? const Color(0xFFE8400A).withOpacity(0.3)
                                  : Colors.grey.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: queue.connected
                                      ? const Color(0xFFE8400A)
                                      : Colors.grey,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                queue.connected
                                    ? 'SYNC_ACTIVE'
                                    : 'SYNC_INACTIVE',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 9,
                                  color: queue.connected
                                      ? const Color(0xFFE8400A)
                                      : Colors.grey,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 8),

                // ── Bottom orange bar (same as WaitRoom) ──
                Container(
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: RadialGradient(
                      colors: [
                        Colors.deepOrange,
                        const Color.fromARGB(255, 20, 19, 19),
                      ],
                      radius: 50,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'BOOT',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'VERIFY',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Expanded(
                              child: LinearProgressIndicator(
                                color: Colors.black,
                                value: 1,
                                minHeight: 5,
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: LinearProgressIndicator(
                                color: Colors.black,
                                value: 1,
                                minHeight: 5,
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'RDY',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 10,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'PRC',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 10,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailChip(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFD6D8DB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: const Color(0xFFE8400A)),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 8,
                  color: Colors.grey.shade500,
                  letterSpacing: 1.0,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  color: const Color(0xFF1A1A1A),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Live weather — identical logic to WaitRoom ──
class _LiveWeather extends StatefulWidget {
  const _LiveWeather();

  @override
  State<_LiveWeather> createState() => __LiveWeatherState();
}

class __LiveWeatherState extends State<_LiveWeather> {
  late Timer _timer;
  double? _temp;
  String? _city;

  @override
  void initState() {
    super.initState();
    _fetchWeatherWeb();
    _timer = Timer.periodic(
      const Duration(minutes: 25),
      (_) => _fetchWeatherWeb(),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _fetchWeatherWeb() {
    html.window.navigator.geolocation
        .getCurrentPosition()
        .then((pos) async {
          final lat = pos.coords!.latitude!;
          final lon = pos.coords!.longitude!;
          final results = await Future.wait([
            Dio().get(
              'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true',
            ),
            Dio().get(
              'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lon&format=json',
              options: Options(headers: {'User-Agent': 'WaitWise/1.0'}),
            ),
          ]);
          final weather = results[0].data;
          final geo = results[1].data;
          setState(() {
            _temp = weather['current_weather']['temperature'];
            _city =
                geo['address']['city'] ??
                geo['address']['town'] ??
                geo['address']['suburb'] ??
                geo['address']['county'] ??
                'Unknown';
          });
        })
        .catchError((e) {
          debugPrint('Location error: $e');
        });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '$_temp°C , $_city',
      style: GoogleFonts.jetBrainsMono(color: Colors.grey),
    );
  }
}
