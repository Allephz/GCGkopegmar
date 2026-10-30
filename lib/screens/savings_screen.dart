// lib/screens/savings_screen.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/responses.dart';
import 'withdrawal_screen.dart';

class SavingsScreen extends StatefulWidget {
  const SavingsScreen({Key? key}) : super(key: key);

  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> {
  final _apiService = ApiService();
  SavingsBalance? _savingsData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavingsData();
  }

  Future<void> _loadSavingsData() async {
    try {
      final userId = _apiService.memberId ?? 'CANDRA';
      final response = await _apiService.getNominalSimpanan(userId);
      setState(() {
        _savingsData = response.data?.first;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading savings: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color successGreen = Color(0xFF10B981);
    const Color bgGray = Color(0xFFF3F4F6);

    return Scaffold(
      backgroundColor: bgGray,
      appBar: AppBar(
        title: const Text('Simpanan'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Total Savings
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          successGreen,
                          successGreen.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Simpanan',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.white70),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Rp ${_savingsData?.totalSavings.toStringAsFixed(0).replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.') ?? '0'}',
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge
                              ?.copyWith(
                                color: Colors.white,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Savings Types
                  Text(
                    'Rincian Simpanan',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 18,
                        ),
                  ),
                  const SizedBox(height: 12),
                  ...[
                    {
                      'type': 'Simpanan Pokok',
                      'amount': _savingsData?.principal ?? 0.0,
                      'icon': Icons.account_balance_wallet,
                      'color': Color(0xFF2563EB),
                    },
                    {
                      'type': 'Simpanan Wajib',
                      'amount': _savingsData?.mandatory ?? 0.0,
                      'icon': Icons.payment,
                      'color': Color(0xFFF59E0B),
                    },
                    {
                      'type': 'Simpanan Sukarela',
                      'amount': _savingsData?.voluntary ?? 0.0,
                      'icon': Icons.pan_tool,
                      'color': Color(0xFF10B981),
                    },
                    {
                      'type': 'Simpanan Khusus',
                      'amount': _savingsData?.special ?? 0.0,
                      'icon': Icons.star,
                      'color': Color(0xFFEF4444),
                    },
                  ].map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFE5E7EB),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color:
                                    (item['color'] as Color).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                item['icon'] as IconData,
                                color: item['color'] as Color,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['type'] as String,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Rp ${(item['amount'] as double).toStringAsFixed(0).replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.')}',
                                    style:
                                        Theme.of(context).textTheme.labelSmall,
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              'Tarik',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: (item['amount'] as double) > 0
                                        ? const Color(0xFF2563EB)
                                        : Colors.grey,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),

                  const SizedBox(height: 24),

                  // Withdrawal History Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        // Navigate to withdrawal history
                      },
                      child: const Text('Riwayat Penarikan'),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Info Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDBEAFE),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF2563EB),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Color(0xFF2563EB),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Simpanan sukarela dan khusus bisa ditarik',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: const Color(0xFF2563EB),
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const WithdrawalScreen(),
            ),
          );
        },
        backgroundColor: successGreen,
        label: const Text('Tarik Simpanan'),
        icon: const Icon(Icons.arrow_downward),
      ),
    );
  }
}
