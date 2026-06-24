import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wait_wise/provider/provider.dart';
import 'package:wait_wise/screens/reception_screen.dart';
import 'package:wait_wise/screens/register.dart';
import 'package:wait_wise/screens/tv_screen.dart';
import 'package:wait_wise/services/authService.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscurePassword = true;
  bool _isLoading = false;

  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }
    String _generateClinicId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ123456789';
    final rand = Random();
    return List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  void _handleLogin(WidgetRef ref) async {
    setState(() => _isLoading = true);

    final res = await AuthService.login(
      email: _userController.text.trim(),
      password: _passController.text.trim(),
    );
    if (res == true) {
      String clinicId = _generateClinicId();
      _connect(ref, clinicId: clinicId, isReceptionist: true);
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _connect(
    WidgetRef ref, {
    required String clinicId,
    required bool isReceptionist,
  }) {
    final url = "http://localhost:9000";
    if (url.isEmpty) return;
    ref.read(serverUrlProvider.notifier).state = url;
    ref.read(clinicIdProvider.notifier).state = clinicId;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            isReceptionist ? ReceptionPage(clinicId: clinicId) : const tv(),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3E5E8),
      body: Row(
        children: [
          // ── LEFT PANEL ──
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 52, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  // Brand
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE8400A),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'WAIT_WISE',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A1A1A),
                          letterSpacing: 3,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  Text(
                    'Queue Management',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A1A),
                      height: 1.25,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'Simplified.',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A1A),
                      height: 1.25,
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'Real-time queue synchronization\nfor modern operations.',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      color: const Color(0xFF888888),
                      height: 1.7,
                      letterSpacing: 0.3,
                    ),
                  ),

                  const SizedBox(height: 40),

                  _featureRow(Icons.bolt_outlined, 'Live queue sync across all nodes'),
                  const SizedBox(height: 14),
                  _featureRow(Icons.bar_chart_outlined, 'Real-time analytics & reporting'),
                  const SizedBox(height: 14),
                  _featureRow(Icons.lock_outline_rounded, 'Role-based access control'),

                  const Spacer(),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _statBox('12K+', 'Active Users'),
                      const SizedBox(width: 24),
                      _statBox('99.9%', 'Uptime'),
                      const SizedBox(width: 24),
                      _statBox('< 50ms', 'Sync Latency'),
                    ],
                  ),

                  const SizedBox(height: 40),

                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE8400A),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'SYSTEM ONLINE',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 9,
                          color: const Color(0xFF888888),
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'v2.4.1 // BUILD_STABLE',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 9,
                          color: const Color(0xFFBBBBBB),
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: 1,
            color: const Color(0xFFD0D2D5),
            margin: const EdgeInsets.symmetric(vertical: 40),
          ),

          Expanded(
            flex: 4,
            child: Center(
              child: Consumer(
                builder:(context, ref, child){
                return Container(
                  height: 500,
                  width: 320,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F6F7),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.13),
                        offset: const Offset(4, 12),
                        blurRadius: 24,
                        spreadRadius: 0,
                      ),
                    ],
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                
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
                              'WAIT_WISE // AUTH',
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
                                'PRT 01',
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
                
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                
                              Text(
                                'LOGIN',
                                style: GoogleFonts.jetBrainsMono(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 26,
                                  color: const Color(0xFF1A1A1A),
                                  letterSpacing: 2,
                                ),
                              ),
                
                              const SizedBox(height: 20),
                
                              Text(
                                'EMAIL_ID',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 10,
                                  color: const Color(0xFF888888),
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 6),
                              _buildField(
                                controller: _userController,
                                hint: 'enter email',
                                icon: Icons.person_outline_rounded,
                                obscure: false,
                              ),
                
                              const SizedBox(height: 14),
                
                              Text(
                                'PASS_KEY',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 10,
                                  color: const Color(0xFF888888),
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 6),
                              _buildField(
                                controller: _passController,
                                hint: '••••••••',
                                icon: Icons.lock_outline_rounded,
                                obscure: _obscurePassword,
                                suffix: GestureDetector(
                                  onTap: () => setState(
                                      () => _obscurePassword = !_obscurePassword),
                                  child: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    size: 16,
                                    color: const Color(0xFF888888),
                                  ),
                                ),
                              ),
                
                              const SizedBox(height: 8),
                
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  'RESET ACCESS?',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 10,
                                    color: const Color(0xFFE8400A),
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                
                              const Spacer(),
                
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFECEDEF),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(0xFFD6D8DB),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _logLine('00:00:01', 'PROTOCOL AUTH READY.',
                                        orange: true),
                                    const SizedBox(height: 2),
                                    _logLine('00:00:02', 'AWAITING CREDENTIALS.',
                                        orange: false),
                                    const SizedBox(height: 2),
                                    _logLine('00:00:03', 'SESSION HOLDING.',
                                        orange: false),
                                  ],
                                ),
                              ),
                
                              const SizedBox(height: 14),
                
                              // Execute button
                              GestureDetector(
                                onTap: _isLoading ? null : (){
                                  _handleLogin(ref);
                                },
                                child: Container(
                                  width: double.infinity,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8400A),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: _isLoading
                                        ? const SizedBox(
                                            height: 18,
                                            width: 18,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Text(
                                            'EXECUTE',
                                            style: GoogleFonts.jetBrainsMono(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 13,
                                              letterSpacing: 2.5,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                
                              const SizedBox(height: 12),
                
                              Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'NO ACCOUNT? ',
                                      style: GoogleFonts.jetBrainsMono(
                                        fontSize: 9,
                                        color: const Color(0xFF888888),
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => RegisterPage(),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        'REGISTER NOW',
                                        style: GoogleFonts.jetBrainsMono(
                                          fontSize: 9,
                                          color: const Color(0xFFE8400A),
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
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
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _featureRow(IconData icon, String label) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 15, color: const Color(0xFFE8400A)),
        const SizedBox(width: 10),
        Text(
          label,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 10,
            color: const Color(0xFF555555),
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _statBox(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A1A),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 9,
            color: const Color(0xFF888888),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool obscure,
    Widget? suffix,
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
              obscureText: obscure,
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
          if (suffix != null) ...[
            suffix,
            const SizedBox(width: 12),
          ],
        ],
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