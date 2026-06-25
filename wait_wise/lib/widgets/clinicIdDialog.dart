import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Future<String?> showClinicIdDialog(BuildContext context) {
  final controller = TextEditingController();

  return showDialog<String>(
    context: context,
    barrierColor: Colors.black.withOpacity(0.3),
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          width: 320,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F6F7),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.13),
                offset: const Offset(4, 12),
                blurRadius: 24,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: const BoxDecoration(
                  color: Color(0xFFE8400A),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'WAIT_WISE // CONNECT',
                      style: GoogleFonts.jetBrainsMono(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context, null),
                      child: const Icon(Icons.close_rounded,
                          color: Colors.white, size: 16),
                    ),
                  ],
                ),
              ),

              // Body
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      'CLINIC_ID',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A1A),
                        letterSpacing: 2,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'Enter the ID shared by your clinic admin.',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        color: const Color(0xFF888888),
                        letterSpacing: 0.3,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Log box
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
                          _logLine('00:00:01', 'PROTOCOL CONNECT READY.', orange: true),
                          const SizedBox(height: 2),
                          _logLine('00:00:02', 'AWAITING CLINIC_ID.', orange: false),
                          const SizedBox(height: 2),
                          _logLine('00:00:03', 'SESSION HOLDING.', orange: false),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Input field label
                    Text(
                      'ENTER_ID',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        color: const Color(0xFF888888),
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Input field
                    Container(
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
                          const Icon(Icons.tag_rounded,
                              size: 16, color: Color(0xFF888888)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: controller,
                              autofocus: true,
                              textCapitalization: TextCapitalization.characters,
                              onSubmitted: (val) {
                                if (val.trim().isNotEmpty) {
                                  Navigator.pop(context, val.trim());
                                }
                              },
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 12,
                                color: const Color(0xFF1A1A1A),
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.5,
                              ),
                              decoration: InputDecoration(
                                hintText: 'e.g. CLINIC_4X9',
                                hintStyle: GoogleFonts.jetBrainsMono(
                                  fontSize: 12,
                                  color: const Color(0xFFAAAAAA),
                                  letterSpacing: 0.5,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Buttons row
                    Row(
                      children: [
                        // Cancel
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context, null),
                            child: Container(
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFFECEDEF),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: const Color(0xFFD6D8DB), width: 1),
                              ),
                              child: Center(
                                child: Text(
                                  'CANCEL',
                                  style: GoogleFonts.jetBrainsMono(
                                    color: const Color(0xFF888888),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Connect
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              final val = controller.text.trim();
                              if (val.isNotEmpty) Navigator.pop(context, val);
                            },
                            child: Container(
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8400A),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  'CONNECT',
                                  style: GoogleFonts.jetBrainsMono(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
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