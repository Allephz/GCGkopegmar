// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/responses.dart';
import 'apply_loan_screen.dart';
import 'withdrawal_screen.dart';
import 'transaction_history_screen.dart';
import 'savings_screen.dart';
import 'loan_list_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _apiService = ApiService();
  int _selectedIndex = 0;

  PersonalData? _userData;
  SavingsBalance? _savingsData;
  double _totalLoanAmount = 0;
  List<dynamic> _recentTransactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      // Use current memberId or default 'CANDRA' for mock mode
      final userId = _apiService.memberId ?? 'CANDRA';

      final personalResponse = await _apiService.getPersonalData(userId);
      final savingsResponse = await _apiService.getNominalSimpanan(userId);
      final transactionsResponse = await _apiService.getRiwayatTransaksi(userId);

      setState(() {
        _userData = personalResponse.data;
        if (savingsResponse.data != null && savingsResponse.data!.isNotEmpty) {
          _savingsData = savingsResponse.data?.first;
        }
        if (transactionsResponse['code'] == 200 && transactionsResponse['data'] != null) {
          _recentTransactions = transactionsResponse['data'];
        }
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onBottomNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF2563EB);
    const Color successGreen = Color(0xFF10B981);
    const Color warningOrange = Color(0xFFF59E0B);
    const Color errorRed = Color(0xFFEF4444);
    const Color bgGray = Color(0xFFF3F4F6);

    return Scaffold(
      backgroundColor: bgGray,
      appBar: _selectedIndex == 0
          ? AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              title: const Text('Dashboard'),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {},
                ),
              ],
            )
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _selectedIndex == 0
              ? SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryBlue, primaryBlue.withOpacity(0.8)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selamat datang kembali,',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white70,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _userData?.name ?? 'Member',
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

                  // Active Loan Card
                  if (_totalLoanAmount > 0)
                    Container(
                      width: double.infinity,
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
                          Text(
                            'Pinjaman Aktif',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Rp ${_totalLoanAmount.toStringAsFixed(0).replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.')}',
                            style: Theme.of(context).textTheme.displayLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Cicilan bulan ini: Rp 500.000',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(color: Colors.black45),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Action Buttons (4 columns)
                  Text(
                    'Aksi Cepat',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 18,
                        ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _ActionButton(
                        icon: Icons.add_circle_outline,
                        label: 'Ajukan Pinjaman',
                        color: primaryBlue,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ApplyLoanScreen(),
                            ),
                          );
                          _loadUserData();
                        },
                      ),
                      _ActionButton(
                        icon: Icons.savings,
                        label: 'Tarik Simpanan',
                        color: successGreen,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const WithdrawalScreen(),
                            ),
                          );
                          _loadUserData();
                        },
                      ),
                      _ActionButton(
                        icon: Icons.history,
                        label: 'Riwayat',
                        color: warningOrange,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const TransactionHistoryScreen(),
                            ),
                          );
                        },
                      ),
                      _ActionButton(
                        icon: Icons.account_balance_wallet,
                        label: 'Saldo Simpanan',
                        color: errorRed,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SavingsScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Recent Transactions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Transaksi Terakhir',
                        style:
                            Theme.of(context).textTheme.displayLarge?.copyWith(
                                  fontSize: 18,
                                ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TransactionHistoryScreen(),
                            ),
                          );
                        },
                        child: const Text('Lihat semua'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: _recentTransactions.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                'Tidak ada transaksi terbaru',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          )
                        : Column(
                            children: [
                              ..._recentTransactions.take(3).map((txn) {
                                final source = txn['source'] ?? '';
                                final jenis = txn['jenis'] ?? '';
                                final docNum = txn['doc_num'] ?? '';
                                final date = txn['doc_date'] ?? '';

                                final isPull = source == 'PULL';
                                final isPnj = source == 'PNJ';

                                final title = isPull
                                    ? 'Tarik Simpanan'
                                    : (isPnj ? 'Pinjaman' : source.toString());

                                final color = isPnj
                                    ? successGreen
                                    : (isPull ? errorRed : primaryBlue);
                                final icon = isPnj
                                    ? Icons.arrow_downward
                                    : (isPull ? Icons.arrow_upward : Icons.swap_horiz);

                                final index = _recentTransactions.indexOf(txn);
                                final isLast = index == _recentTransactions.length - 1 || index == 2;

                                return Column(
                                  children: [
                                    _TransactionItem(
                                      icon: icon,
                                      title: title,
                                      date: '$jenis - $date',
                                      amount: docNum,
                                      amountColor: color,
                                    ),
                                    if (!isLast) const Divider(height: 16),
                                  ],
                                );
                              }).toList(),
                            ],
                          ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            )
          : _selectedIndex == 1
              ? const LoanListScreen()
              : _selectedIndex == 2
                  ? const SavingsScreen()
                  : const ProfileScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article_outlined),
            activeIcon: Icon(Icons.article),
            label: 'Pinjaman',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.savings_outlined),
            activeIcon: Icon(Icons.savings),
            label: 'Simpanan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String date;
  final String amount;
  final Color amountColor;

  const _TransactionItem({
    required this.icon,
    required this.title,
    required this.date,
    required this.amount,
    required this.amountColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: amountColor, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                date,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ),
        Text(
          amount,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: amountColor,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
