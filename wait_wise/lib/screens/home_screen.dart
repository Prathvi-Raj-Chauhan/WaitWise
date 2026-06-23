import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wait_wise/provider/provider.dart';
import 'package:wait_wise/screens/reception_screen.dart';
import 'package:wait_wise/screens/tv_screen.dart';

class WW {
  static const bg = Color(0xFF0F172A);
  static const surface = Color(0xFF1E293B);
  static const surfaceHigh = Color(0xFF334155);
  static const teal = Color(0xFF14B8A6);
  static const amber = Color(0xFFF59E0B);
  static const textPrimary = Color(0xFFF8FAFC);
  static const textSecondary = Color(0xFF94A3B8);

  static const r12 = BorderRadius.all(Radius.circular(12));
  static const r16 = BorderRadius.all(Radius.circular(16));
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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _urlController = TextEditingController(text: 'http://localhost:9000');
  final _clinicIdController = TextEditingController();

  @override
  void dispose() {
    _urlController.dispose();
    _clinicIdController.dispose();
    super.dispose();
  }

  String _generateClinicId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ123456789';
    final rand = Random();
    return List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  void _connect(WidgetRef ref, {required String clinicId, required bool isReceptionist}) {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;
    ref.read(serverUrlProvider.notifier).state = url;
    ref.read(clinicIdProvider.notifier).state = clinicId;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => isReceptionist ? ReceptionPage(clinicId: clinicId) : const tv(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WW.bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Consumer(
                builder: (context, ref, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: WW.teal.withOpacity(0.15),
                              borderRadius: WW.r12,
                              border: Border.all(color: WW.teal.withOpacity(0.4), width: 1),
                            ),
                            child: const Icon(Icons.access_time_rounded, color: WW.teal, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'WaitWise',
                                style: TextStyle(
                                  color: WW.textPrimary,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const Text(
                                'Queue management',
                                style: TextStyle(color: WW.textSecondary, fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      const Text(
                        'CONNECTION',
                        style: TextStyle(
                          color: WW.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _urlController,
                        style: const TextStyle(color: WW.textPrimary, fontSize: 14),
                        decoration: WW.inputDeco('Server URL', icon: Icons.dns_outlined),
                      ),
                      const SizedBox(height: 28),
                      _CardSection(
                        icon: Icons.badge_outlined,
                        iconColor: WW.teal,
                        title: 'Receptionist Mode',
                        subtitle: 'Manage the queue, add patients, and call the next token.',
                        child: _PrimaryButton(
                          label: 'Open as Receptionist',
                          icon: Icons.login_rounded,
                          onPressed: () {
                            final id = _generateClinicId();
                            _connect(ref, clinicId: id, isReceptionist: true);
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      _CardSection(
                        icon: Icons.tv_rounded,
                        iconColor: WW.amber,
                        title: 'Display / TV Mode',
                        subtitle: 'Show the live queue on a waiting-room screen.',
                        child: Column(
                          children: [
                            TextField(
                              controller: _clinicIdController,
                              style: const TextStyle(color: WW.textPrimary, fontSize: 14),
                              decoration: WW.inputDeco('Clinic ID', icon: Icons.tag_rounded),
                            ),
                            const SizedBox(height: 12),
                            _PrimaryButton(
                              label: 'Open as Display',
                              icon: Icons.cast_rounded,
                              color: WW.amber,
                              onPressed: () {
                                final id = _clinicIdController.text.trim();
                                if (id.isEmpty) return;
                                _connect(ref, clinicId: id, isReceptionist: false);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CardSection extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget child;

  const _CardSection({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: WW.surface,
        borderRadius: WW.r20,
        border: Border.all(color: WW.surfaceHigh, width: 1),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: WW.r12,
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: WW.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: WW.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.color = WW.teal,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: WW.bg,
          padding: const EdgeInsets.symmetric(vertical: 14),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: WW.r12),
          elevation: 0,
        ),
      ),
    );
  }
}