// lib/screens/loan_list_screen.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/responses.dart';

class LoanListScreen extends StatefulWidget {
  const LoanListScreen({Key? key}) : super(key: key);

  @override
  State<LoanListScreen> createState() => _LoanListScreenState();
}

class _LoanListScreenState extends State<LoanListScreen> {
  final _apiService = ApiService();
  int _selectedTabIndex = 0;
  List<LoanHistory>? _allLoans;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLoans();
  }

  Future<void> _loadLoans() async {
    try {
      final userId = _apiService.memberId ?? 'CANDRA';
      final response = await _apiService.getLoanHistory(userId);
      setState(() {
        _allLoans = response.data;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading loans: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<LoanHistory> get _filteredLoans {
    if (_allLoans == null) return [];

    switch (_selectedTabIndex) {
      case 0: // Aktif
        return _allLoans!.where((l) => l.status == 'ACTIVE').toList();
      case 1: // Riwayat
        return _allLoans!.where((l) => l.status == 'COMPLETED').toList();
      case 2: // Ditolak
        return _allLoans!.where((l) => l.status == 'REJECTED').toList();
      default:
        return _allLoans ?? [];
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF2563EB);
    const Color successGreen = Color(0xFF10B981);
    const Color errorRed = Color(0xFFEF4444);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Pinjaman'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Tabs
          Container(
            color: Colors.white,
            child: Row(
              children: List.generate(3, (index) {
                final tabs = ['Aktif', 'Riwayat', 'Ditolak'];
                final isSelected = _selectedTabIndex == index;
                return Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedTabIndex = index;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color:
                                isSelected ? primaryBlue : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Text(
                        tabs[index],
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: isSelected ? primaryBlue : Colors.black45,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const Divider(height: 1),
          // Loan List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredLoans.isEmpty
                    ? Center(
                        child: Text(
                          'Tidak ada pinjaman',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.black45,
                                  ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredLoans.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final loan = _filteredLoans[index];
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Pinjaman #${loan.docNumber}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(loan.status)
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: _getStatusColor(loan.status),
                                        ),
                                      ),
                                      child: Text(
                                        loan.status ?? 'UNKNOWN',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                              color:
                                                  _getStatusColor(loan.status),
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Rp ${loan.amount.toStringAsFixed(0).replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.')}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayLarge
                                      ?.copyWith(
                                        fontSize: 20,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${loan.tenor} bulan',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall,
                                    ),
                                    Text(
                                      loan.docDate ?? '-',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to apply loan
        },
        backgroundColor: primaryBlue,
        label: const Text('Ajukan Pinjaman'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'ACTIVE':
        return const Color(0xFF10B981);
      case 'COMPLETED':
        return const Color(0xFF6B7280);
      case 'REJECTED':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFFF59E0B);
    }
  }
}
