import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wait_wise/provider/provider.dart';
import 'package:wait_wise/screens/doctor_screen.dart';
import 'package:wait_wise/screens/reception_screen.dart';
import 'package:wait_wise/screens/wait_room.dart';
import 'package:wait_wise/widgets/clinicIdDialog.dart';

class RoleSelectPage extends StatefulWidget {

  const RoleSelectPage({super.key});

  @override
  State<RoleSelectPage> createState() => _RoleSelectPageState();
}

class _RoleSelectPageState extends State<RoleSelectPage> {
  String? _selected; // 'doctor' | 'reception' | null
  bool _isLoading = false;
  void _connect(
    WidgetRef ref, {
    required String clinicId,
    required bool isReceptionist,
  }) {
    final url = "http://localhost:9000";
    if (url.isEmpty) return;
    ref.read(serverUrlProvider.notifier).state = url;
    ref.read(clinicIdProvider.notifier).state = clinicId;
    
    if (mounted) {
      
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => isReceptionist ? ReceptionPage( clinicId : clinicId)  : DoctorScreen()))
      ;
    }
  
  }
    String _generateClinicId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ123456789';
    final rand = Random();
    return List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
  }
  void _proceed(WidgetRef ref) async{
    if (_selected == null) return;
    if (_selected == 'doctor') {
      final clinicId = await showClinicIdDialog(context);
      _connect(ref, clinicId: clinicId!, isReceptionist: false);
    } else {
      final String clinicId = _generateClinicId();
      _connect(ref, clinicId: clinicId, isReceptionist: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3E5E8),
      body: Stack(
        children: [
          // ── background meta text ──
          Positioned(
            top: 40,
            left: 48,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'WAIT_WISE',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A1A),
                    letterSpacing: 2.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'SELECT OPERATOR MODE',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 9,
                    color: const Color(0xFF888888),
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 40,
            left: 48,
            child: Text(
              'v2.4.1 // BUILD_STABLE',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 9,
                color: const Color(0xFFBBBBBB),
                letterSpacing: 1.0,
              ),
            ),
          ),

          Positioned(
            bottom: 40,
            right: 48,
            child: Text(
              'NODE_01 // REGION_IN',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 9,
                color: const Color(0xFFBBBBBB),
                letterSpacing: 1.0,
              ),
            ),
          ),

          // ── card ──
          Center(
            child: Container(
              width: 340,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6F7),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.13),
                    offset: const Offset(4, 12),
                    blurRadius: 24,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8400A),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'WAIT_WISE // MODE_SELECT',
                          style: GoogleFonts.jetBrainsMono(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'PRT 02',
                            style: GoogleFonts.jetBrainsMono(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text(
                          'SELECT ROLE',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1A1A1A),
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Choose how you will use this session.',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            color: const Color(0xFF888888),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ── Doctor tile ──
                        _roleTile(
                          id: 'doctor',
                          icon: Icons.medical_information,
                          title: 'DOCTOR',
                          subtitle: 'View patient details\nand manage consultations',
                        ),

                        const SizedBox(height: 12),

                        // ── Reception tile ──
                        _roleTile(
                          id: 'reception',
                          icon: Icons.event_note_outlined,
                          title: 'RECEPTION',
                          subtitle: 'Register patients\nand manage the queue',
                        ),

                        const SizedBox(height: 24),

                        // ── Log box ──
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECEDEF),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFD6D8DB), width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _logLine('00:00:01', 'AUTH PROTOCOL COMPLETE.', orange: true),
                              const SizedBox(height: 2),
                              _logLine('00:00:02', 'AWAITING MODE SELECTION.', orange: false),
                              const SizedBox(height: 2),
                              _logLine(
                                '00:00:03',
                                _selected == null
                                    ? 'SESSION HOLDING.'
                                    : 'MODE: ${_selected!.toUpperCase()} SELECTED.',
                                orange: _selected != null,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ── Proceed button ──
                        Consumer(
                          builder: (context, ref, child)  {
                            return GestureDetector(
                            onTap: (){
                              _selected != null ? _proceed(ref) : null;
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: double.infinity,
                              height: 46,
                              decoration: BoxDecoration(
                                color: _selected != null
                                    ? const Color(0xFFE8400A)
                                    : const Color(0xFFD6D8DB),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  'PROCEED',
                                  style: GoogleFonts.jetBrainsMono(
                                    color: _selected != null
                                        ? Colors.white
                                        : const Color(0xFF888888),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    letterSpacing: 2.5,
                                  ),
                                ),
                              ),
                            ),
                          );
                          },
                         
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _roleTile({
    required String id,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _selected == id;
    return GestureDetector(
      onTap: () => setState(() => _selected = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFE8400A).withOpacity(0.07)
              : const Color(0xFFECEDEF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFE8400A).withOpacity(0.5)
                : const Color(0xFFD6D8DB),
            width: isSelected ? 1.5 : 1,
          ),
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
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFE8400A).withOpacity(0.12)
                    : const Color(0xFFF5F6F7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFE8400A).withOpacity(0.3)
                      : const Color(0xFFD6D8DB),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected
                    ? const Color(0xFFE8400A)
                    : const Color(0xFF888888),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? const Color(0xFF1A1A1A)
                          : const Color(0xFF555555),
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 9,
                      color: const Color(0xFF888888),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            // selection indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? const Color(0xFFE8400A)
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFE8400A)
                      : const Color(0xFFD6D8DB),
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded,
                      size: 11, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _logLine(String time, String msg, {required bool orange}) {
    return Row(
      children: [
        Text(
          time,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 9,
            color: orange ? const Color(0xFFE8400A) : const Color(0xFF888888),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          msg,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 9,
            color: const Color(0xFF555555),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}