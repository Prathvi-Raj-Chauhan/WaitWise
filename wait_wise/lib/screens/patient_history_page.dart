import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wait_wise/model/PatientHistory.dart';
import 'package:wait_wise/services/dioClient.dart';

// Model for history records

class PatientHistoryPage extends StatefulWidget {
  const PatientHistoryPage({super.key});

  @override
  State<PatientHistoryPage> createState() => _PatientHistoryPageState();
}

class _PatientHistoryPageState extends State<PatientHistoryPage> {
  final _searchController = TextEditingController();
  DateTimeRange? _selectedRange;
  String _selectedStatus = 'all';
  bool _isLoading = false;
  List<PatientRecord> _records = [];
  List<PatientRecord> _filtered = [];
  late var clinicId = "";
  Future<void> setupClinicId() async {
    final pref = await SharedPreferences.getInstance();
    final id = pref.get('clinicDbId')?.toString() ?? '';
    setState(() {
      clinicId = id;
    });
  }

  Future<void> _fetchHistory() async {
    setState(() => _isLoading = true);

    try {
      final queryParams = <String, dynamic>{};

      if (_selectedRange != null) {
        queryParams['from'] = _selectedRange!.start.toIso8601String();
        queryParams['to'] = _selectedRange!.end.toIso8601String();
      }

      if (_selectedStatus != 'all') {
        queryParams['status'] = _selectedStatus;
      }

      // Name search is handled client-side for instant feedback,
      // but you can also pass it here if you want server-side filtering:
      // if (_searchController.text.trim().isNotEmpty) {
      //   queryParams['name'] = _searchController.text.trim();
      // }

      final response = await Dioclient.dio.get(
        '/history/${clinicId}',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      // Backend returns { count: int, records: [...] }
      final List<dynamic> raw = response.data['records'] ?? [];

      final parsed = raw.map((json) {
        // addedAt is stored as a ms-epoch string, e.g. "1718000000000"
        final addedAtRaw = json['addedAt'];
        final addedAtMs = int.tryParse(addedAtRaw.toString());
        final addedAt = addedAtMs != null
            ? DateTime.fromMillisecondsSinceEpoch(addedAtMs)
            : DateTime.tryParse(addedAtRaw.toString()) ?? DateTime.now();

        return PatientRecord(
          id: json['id'],
          name: json['name'] ?? '',
          age: json['age'],
          gender: json['gender'],
          bloodPressure: json['bloodPressure'],
          weight: json['weight']?.toString(),
          reason: json['reason'] ?? '',
          address: json['address'],
          status: json['status'] ?? 'pending',
          addedAt: addedAt,
        );
      }).toList();

      setState(() {
        _records = parsed;
        _isLoading = false;
      });

      _applyFilters();
    } on DioException catch (e) {
      setState(() => _isLoading = false);

      final msg = e.response?.data?['error'] ?? 'Failed to fetch history';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: const Color(0xFFE8400A),
          ),
        );
      }
    }
  }

  void _applyFilters() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filtered = _records.where((r) {
        final matchName = query.isEmpty || r.name.toLowerCase().contains(query);
        final matchStatus =
            _selectedStatus == 'all' || r.status == _selectedStatus;
        final matchDate =
            _selectedRange == null ||
            (r.addedAt.isAfter(
                  _selectedRange!.start.subtract(const Duration(days: 1)),
                ) &&
                r.addedAt.isBefore(
                  _selectedRange!.end.add(const Duration(days: 1)),
                ));
        return matchName && matchStatus && matchDate;
      }).toList();
    });
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      initialDateRange: _selectedRange,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFFE8400A),
            onPrimary: Colors.white,
            surface: Color(0xFFF5F6F7),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedRange = picked);
      _applyFilters();
    }
  }

  void _clearFilters() {
    _searchController.clear();
    setState(() {
      _selectedRange = null;
      _selectedStatus = 'all';
      _filtered = List.from(_records);
    });
  }

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';

  @override
  void initState() {
    super.initState();
    _initAndFetch();
  }

  Future<void> _initAndFetch() async {
    await setupClinicId(); // wait for clinicId to be ready
    _fetchHistory(); // only then fetch
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3E5E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F6F7),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Color(0xFF888888),
            size: 20,
          ),
          onPressed: () => context.go('/doctor'),
        ),
        title: Row(
          children: [
            GestureDetector(
              onTap: (){
                _fetchHistory();
              },
              child: const Icon(
                Icons.history_rounded,
                color: Color(0xFFE8400A),
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'PATIENT HISTORY',
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
          // record count badge
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFECEDEF),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFD6D8DB), width: 1),
            ),
            child: Text(
              '${_filtered.length} records',
              style: GoogleFonts.jetBrainsMono(
                color: const Color(0xFF555555),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Filter bar ──
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6F7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD6D8DB), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    offset: const Offset(0, 4),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'FILTERS',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 9,
                      color: const Color(0xFF888888),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      // search field
                      Expanded(
                        flex: 3,
                        child: _filterField(
                          controller: _searchController,
                          hint: 'search by name...',
                          icon: Icons.search_rounded,
                          onChanged: (_) => _applyFilters(),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // date range picker
                      Expanded(
                        flex: 3,
                        child: GestureDetector(
                          onTap: _pickDateRange,
                          child: Container(
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFFECEDEF),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _selectedRange != null
                                    ? const Color(0xFFE8400A).withOpacity(0.5)
                                    : const Color(0xFFD6D8DB),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                const SizedBox(width: 12),
                                Icon(
                                  Icons.date_range_rounded,
                                  size: 15,
                                  color: _selectedRange != null
                                      ? const Color(0xFFE8400A)
                                      : const Color(0xFF888888),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _selectedRange == null
                                        ? 'date range'
                                        : '${_formatDate(_selectedRange!.start)}  →  ${_formatDate(_selectedRange!.end)}',
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 11,
                                      color: _selectedRange != null
                                          ? const Color(0xFF1A1A1A)
                                          : const Color(0xFFAAAAAA),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      // clear button
                      GestureDetector(
                        onTap: _clearFilters,
                        child: Container(
                          height: 44,
                          width: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFECEDEF),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFFD6D8DB),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.clear_rounded,
                            size: 16,
                            color: Color(0xFF888888),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // status pills
                  Row(
                    children: ['all', 'pending', 'done'].map((s) {
                      final active = _selectedStatus == s;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _selectedStatus = s);
                            _applyFilters();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: active
                                  ? const Color(0xFFE8400A).withOpacity(0.1)
                                  : const Color(0xFFECEDEF),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: active
                                    ? const Color(0xFFE8400A).withOpacity(0.5)
                                    : const Color(0xFFD6D8DB),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              s.toUpperCase(),
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: active
                                    ? const Color(0xFFE8400A)
                                    : const Color(0xFF555555),
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── List ──
            Expanded(
              child: _isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Color(0xFFE8400A),
                              strokeWidth: 2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'FETCHING RECORDS...',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 10,
                              color: const Color(0xFF888888),
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    )
                  : _filtered.isEmpty
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
                                color: const Color(0xFFD6D8DB),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.inbox_outlined,
                              color: Color(0xFF888888),
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'NO RECORDS FOUND',
                            style: GoogleFonts.jetBrainsMono(
                              color: const Color(0xFF1A1A1A),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Try adjusting your filters.',
                            style: GoogleFonts.jetBrainsMono(
                              color: const Color(0xFF888888),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: _filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) => _recordCard(_filtered[i]),
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
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8400A),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'HISTORY_VIEW // READ_ONLY // CLINIC_${clinicId.toUpperCase()}',
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
  }

  Widget _recordCard(PatientRecord r) {
    final isDone = r.status == 'done';
    return GestureDetector(
      onTap: () => _showDetailSheet(r),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F6F7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFD6D8DB), width: 1),
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
            // status indicator
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDone
                    ? const Color(0xFFE8400A).withOpacity(0.08)
                    : const Color(0xFFECEDEF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDone
                      ? const Color(0xFFE8400A).withOpacity(0.3)
                      : const Color(0xFFD6D8DB),
                  width: 1,
                ),
              ),
              child: Icon(
                isDone
                    ? Icons.check_circle_outline_rounded
                    : Icons.pending_outlined,
                size: 18,
                color: isDone
                    ? const Color(0xFFE8400A)
                    : const Color(0xFF888888),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.name,
                    style: GoogleFonts.jetBrainsMono(
                      color: const Color(0xFF1A1A1A),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    r.reason,
                    style: GoogleFonts.jetBrainsMono(
                      color: const Color(0xFF888888),
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // status pill
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: isDone
                        ? const Color(0xFFE8400A).withOpacity(0.1)
                        : const Color(0xFFECEDEF),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDone
                          ? const Color(0xFFE8400A).withOpacity(0.4)
                          : const Color(0xFFD6D8DB),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    r.status.toUpperCase(),
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                      color: isDone
                          ? const Color(0xFFE8400A)
                          : const Color(0xFF888888),
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(r.addedAt),
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 9,
                    color: const Color(0xFFBBBBBB),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailSheet(PatientRecord r) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F6F7),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.13),
              offset: const Offset(0, -4),
              blurRadius: 24,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // header
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
                    'WAIT_WISE // PATIENT_DETAIL',
                    style: GoogleFonts.jetBrainsMono(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 16,
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
                  // name + date
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              r.name.toUpperCase(),
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1A1A1A),
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatDate(r.addedAt),
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 10,
                                color: const Color(0xFF888888),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: r.status == 'done'
                              ? const Color(0xFFE8400A).withOpacity(0.1)
                              : const Color(0xFFECEDEF),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: r.status == 'done'
                                ? const Color(0xFFE8400A).withOpacity(0.4)
                                : const Color(0xFFD6D8DB),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          r.status.toUpperCase(),
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: r.status == 'done'
                                ? const Color(0xFFE8400A)
                                : const Color(0xFF888888),
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // detail chips
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      if (r.age != null)
                        _detailChip('AGE', '${r.age} yrs', Icons.cake_outlined),
                      if (r.gender != null && r.gender!.isNotEmpty)
                        _detailChip(
                          'GENDER',
                          r.gender!,
                          Icons.person_outline_rounded,
                        ),
                      if (r.bloodPressure != null &&
                          r.bloodPressure!.isNotEmpty)
                        _detailChip(
                          'BP',
                          r.bloodPressure!,
                          Icons.favorite_outline_rounded,
                        ),
                      if (r.weight != null && r.weight!.isNotEmpty)
                        _detailChip(
                          'WEIGHT',
                          '${r.weight} kg',
                          Icons.monitor_weight_outlined,
                        ),
                      if (r.address != null && r.address!.isNotEmpty)
                        _detailChip(
                          'ADDR',
                          r.address!,
                          Icons.location_on_outlined,
                        ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // reason box
                  Text(
                    'REASON_FOR_VISIT',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 9,
                      color: const Color(0xFFE8400A),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECEDEF),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFFD6D8DB),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      r.reason,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 12,
                        color: const Color(0xFF1A1A1A),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    ValueChanged<String>? onChanged,
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
          Icon(icon, size: 15, color: const Color(0xFF888888)),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 12,
                color: const Color(0xFF1A1A1A),
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

  Widget _detailChip(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F7),
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
