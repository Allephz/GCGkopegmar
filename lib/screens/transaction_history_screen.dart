// lib/screens/transaction_history_screen.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({Key? key}) : super(key: key);

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final _apiService = ApiService();
  bool _isLoading = true;
  List<dynamic> _transactions = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    try {
      final userId = _apiService.memberId ?? 'CANDRA';
      final response = await _apiService.getRiwayatTransaksi(userId);
      if (response['code'] == 200 && response['data'] != null) {
        setState(() {
          _transactions = response['data'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Gagal mengambil riwayat transaksi';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color successGreen = Color(0xFF10B981);
    const Color errorRed = Color(0xFFEF4444);
    const Color primaryBlue = Color(0xFF2563EB);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: errorRed),
                    ),
                  ),
                )
              : _transactions.isEmpty
                  ? const Center(
                      child: Text('Tidak ada riwayat transaksi.'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _transactions.length,
                      itemBuilder: (context, index) {
                        final txn = _transactions[index];
                        final source = txn['source'] ?? '';
                        final jenis = txn['jenis'] ?? '';
                        final aprinfo = txn['aprinfo'] ?? '';
                        final docNum = txn['doc_num'] ?? '-';
                        final date = txn['doc_date'] ?? '-';

                        final isPull = source == 'PULL';
                        final isPnj = source == 'PNJ';

                        final title = isPull
                            ? 'Tarik Simpanan'
                            : (isPnj ? 'Pinjaman' : source.toString());

                        String subTitle = jenis.toString();
                        if (jenis == 'SS') {
                          subTitle = 'Simpanan Sukarela';
                        } else if (jenis == 'SKP') {
                          subTitle = 'Simpanan Khusus Pagu';
                        } else if (jenis == 'SK') {
                          subTitle = 'Simpanan Khusus';
                        } else if (jenis == 'JAPAN') {
                          subTitle = 'Jangka Panjang';
                        } else if (jenis == 'RUMAH') {
                          subTitle = 'Rumah';
                        } else if (jenis == 'MOBIL') {
                          subTitle = 'Mobil';
                        } else if (jenis == 'BRANG') {
                          subTitle = 'Kredit Barang';
                        } else if (jenis == 'JAPEN') {
                          subTitle = 'Jangka Pendek';
                        }

                        final color = isPnj
                            ? successGreen
                            : (isPull ? errorRed : primaryBlue);
                        final icon = isPnj
                            ? Icons.arrow_downward
                            : (isPull ? Icons.arrow_upward : Icons.swap_horiz);

                        String statusLabel = 'Menunggu';
                        Color statusColor = Colors.orange;
                        if (aprinfo.toString().startsWith('A')) {
                          statusLabel = 'Disetujui';
                          statusColor = successGreen;
                        } else if (aprinfo.toString().startsWith('R')) {
                          statusLabel = 'Ditolak';
                          statusColor = errorRed;
                        }

                        return Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Timeline dot & line
                                Column(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: color,
                                      ),
                                    ),
                                    if (index < _transactions.length - 1)
                                      Container(
                                        width: 2,
                                        height: 60,
                                        color: const Color(0xFFE5E7EB),
                                      ),
                                  ],
                                ),
                                const SizedBox(width: 16),
                                // Transaction Details
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: const Color(0xFFE5E7EB),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: color.withOpacity(0.1),
                                          ),
                                          child: Icon(
                                            icon,
                                            color: color,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                title,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '$subTitle\n$date',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelSmall,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              docNum,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    color: color,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 12,
                                                  ),
                                            ),
                                            const SizedBox(height: 4),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color:
                                                    statusColor.withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                statusLabel,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelSmall
                                                    ?.copyWith(
                                                      color: statusColor,
                                                      fontSize: 10,
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
                          ],
                        );
                      },
                    ),
    );
  }
}
