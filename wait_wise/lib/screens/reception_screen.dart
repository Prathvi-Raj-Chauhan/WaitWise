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
              icon: const Icon(Icons.arrow_back_rounded,
                  color: Color(0xFF888888), size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: Row(
              children: [
                const Icon(Icons.local_hospital_outlined,
                    color: Color(0xFFE8400A), size: 16),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECEDEF),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: const Color(0xFFD6D8DB), width: 1),
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
                      const Icon(Icons.copy_rounded,
                          color: Color(0xFF888888), size: 12),
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
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: queue.connected
                            ? const Color(0xFFE8400A)
                            : const Color(0xFFBBBBBB),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      queue.connected ? 'LIVE' : 'OFFLINE',
                      style: GoogleFonts.jetBrainsMono(
                        color: queue.connected
                            ? const Color(0xFFE8400A)
                            : const Color(0xFFBBBBBB),
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
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Now Serving + Stats row ──
                Row(
                  children: [
                    // Now serving card
                    Expanded(
                      flex: 3,
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F6F7),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: const Color(0xFFD6D8DB), width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.07),
                              offset: const Offset(0, 4),
                              blurRadius: 14,
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
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.8,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    queue.currentToken != null
                                        ? '#${queue.currentToken!.number}'
                                        : '—',
                                    style: GoogleFonts.jetBrainsMono(
                                      color: const Color(0xFF1A1A1A),
                                      fontSize: 44,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -2,
                                      height: 1,
                                    ),
                                  ),
                                  if (queue.currentToken != null) ...[
                                    const SizedBox(height: 3),
                                    Text(
                                      queue.currentToken!.name,
                                      style: GoogleFonts.jetBrainsMono(
                                        color: const Color(0xFF888888),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Stats column
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          _statCard(
                            label: 'WAITING',
                            value: '${queue.waitingCount}',
                            icon: Icons.people_outline_rounded,
                          ),
                          const SizedBox(height: 10),
                          _statCard(
                            label: 'TOTAL TODAY',
                            value: '${queue.waitingCount + (queue.currentToken != null ? 1 : 0)}',
                            icon: Icons.bar_chart_rounded,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ── Queue header + Add button ──
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
                    GestureDetector(
                      onTap: () => _showAddPatientDialog(context, ref),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8400A),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.add_rounded,
                                color: Colors.white, size: 14),
                            const SizedBox(width: 5),
                            Text(
                              'NEW PATIENT',
                              style: GoogleFonts.jetBrainsMono(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
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
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFECEDEF),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                      color: const Color(0xFFD6D8DB), width: 1),
                                ),
                                child: const Icon(
                                  Icons.check_circle_outline_rounded,
                                  color: Color(0xFFE8400A),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Queue is empty',
                                style: GoogleFonts.jetBrainsMono(
                                  color: const Color(0xFF1A1A1A),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Tap NEW PATIENT to register.',
                                style: GoogleFonts.jetBrainsMono(
                                  color: const Color(0xFF888888),
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          itemCount: queue.waiting.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
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
                                      ? const Color(0xFFE8400A)
                                          .withOpacity(0.4)
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
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: isNext
                                          ? const Color(0xFFE8400A)
                                              .withOpacity(0.1)
                                          : const Color(0xFFECEDEF),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isNext
                                            ? const Color(0xFFE8400A)
                                                .withOpacity(0.3)
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFECEDEF),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          color: const Color(0xFFD6D8DB),
                                          width: 1),
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECEDEF),
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: const Color(0xFFD6D8DB), width: 1),
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

  Widget _statCard({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD6D8DB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 3),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF888888)),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.jetBrainsMono(
                  color: const Color(0xFF1A1A1A),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.jetBrainsMono(
                  color: const Color(0xFF888888),
                  fontSize: 8,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddPatientDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final ageController = TextEditingController();
    final bpController = TextEditingController();
    final weightController = TextEditingController();
    final reasonController = TextEditingController();
    final addressController = TextEditingController();
    final mobileController = TextEditingController();
    String selectedGender = '';

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Container(
                width: 360,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6F7),
                  borderRadius: BorderRadius.circular(20),
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

                    // Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
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
                            'WAIT_WISE // NEW PATIENT',
                            style: GoogleFonts.jetBrainsMono(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(Icons.close_rounded,
                                color: Colors.white, size: 16),
                          ),
                        ],
                      ),
                    ),

                    // Form body
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Text(
                              'REGISTER',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1A1A1A),
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Fields marked * are required.',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 9,
                                color: const Color(0xFF888888),
                              ),
                            ),

                            const SizedBox(height: 18),

                            // ── Name + Age row ──
                            Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: _dialogField(
                                    controller: nameController,
                                    label: 'PATIENT NAME *',
                                    hint: 'full name',
                                    icon: Icons.person_outline_rounded,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  flex: 2,
                                  child: _dialogField(
                                    controller: ageController,
                                    label: 'AGE',
                                    hint: 'yrs',
                                    icon: Icons.cake_outlined,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 14),

                            // ── Gender selector ──
                            Text(
                              'GENDER',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 9,
                                color: const Color(0xFF888888),
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: ['M', 'F', 'Other'].map((g) {
                                final selected = selectedGender == g;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: GestureDetector(
                                    onTap: () => setDialogState(
                                        () => selectedGender = g),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 9),
                                      decoration: BoxDecoration(
                                        color: selected
                                            ? const Color(0xFFE8400A)
                                                .withOpacity(0.1)
                                            : const Color(0xFFECEDEF),
                                        borderRadius:
                                            BorderRadius.circular(10),
                                        border: Border.all(
                                          color: selected
                                              ? const Color(0xFFE8400A)
                                                  .withOpacity(0.5)
                                              : const Color(0xFFD6D8DB),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        g,
                                        style: GoogleFonts.jetBrainsMono(
                                          color: selected
                                              ? const Color(0xFFE8400A)
                                              : const Color(0xFF555555),
                                          fontSize: 11,
                                          fontWeight: selected
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),

                            const SizedBox(height: 14),

                            // ── BP + Weight row ──
                            Row(
                              children: [
                                Expanded(
                                  child: _dialogField(
                                    controller: bpController,
                                    label: 'BLOOD PRESSURE',
                                    hint: '120/80',
                                    icon: Icons.favorite_outline_rounded,
                                    keyboardType: TextInputType.text,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _dialogField(
                                    controller: weightController,
                                    label: 'WEIGHT',
                                    hint: 'kg',
                                    icon: Icons.monitor_weight_outlined,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 14),

                            // ── Reason ──
                            _dialogField(
                              controller: reasonController,
                              label: 'REASON FOR VISIT *',
                              hint: 'brief reason...',
                              icon: Icons.notes_rounded,
                            ),

                            const SizedBox(height: 14),

                            // ── Address ──
                            _dialogField(
                              controller: addressController,
                              label: 'ADDRESS',
                              hint: 'area / city',
                              icon: Icons.location_on_outlined,
                            ),
                            const SizedBox(height: 14),

                            // ── Address ──
                            _dialogField(
                              controller: mobileController,
                              label: 'Mobile',
                              hint: '+91 ...',
                              icon: Icons.phone_android,
                            ),

                            const SizedBox(height: 20),

                            // ── Buttons ──
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => Navigator.pop(context),
                                    child: Container(
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFECEDEF),
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        border: Border.all(
                                            color: const Color(0xFFD6D8DB),
                                            width: 1),
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
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      final name =
                                          nameController.text.trim();
                                      final reason =
                                          reasonController.text.trim();
                                      final age = ageController.text.trim();
                                      final weight = weightController.text.trim();
                                      final bloodPressure = bpController.text.trim();
                                      final address = addressController.text.trim();
                                      final mobile = mobileController.text.trim();
                                      final gender = selectedGender;
                                      if (name.isEmpty || reason.isEmpty) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'NAME and REASON are required.',
                                              style:
                                                  GoogleFonts.jetBrainsMono(
                                                      fontSize: 11),
                                            ),
                                            backgroundColor:
                                                const Color(0xFFE8400A),
                                            duration: const Duration(
                                                seconds: 2),
                                          ),
                                        );
                                        return;
                                      }
                                      ref
                                          .read(queueProvider.notifier)
                                          .addPatient(address: address, age: age, bloodPressure: bloodPressure, name: name, reason: reason, weight: weight, gender: gender, mobile : mobile);
                                      // TODO: also pass age, gender, bp,
                                      // weight, reason, address to backend
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE8400A),
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'REGISTER',
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
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _dialogField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 9,
            color: const Color(0xFF888888),
            fontWeight: FontWeight.w500,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 5),
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
              const SizedBox(width: 10),
              Icon(icon, size: 15, color: const Color(0xFF888888)),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
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
        ),
      ],
    );
  }
}