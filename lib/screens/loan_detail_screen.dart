// lib/screens/loan_detail_screen.dart
import 'package:flutter/material.dart';

class LoanDetailScreen extends StatefulWidget {
  final String docNumber;
  final double amount;
  final String status;
  final int tenor;

  const LoanDetailScreen({
    Key? key,
    required this.docNumber,
    required this.amount,
    required this.status,
    required this.tenor,
  }) : super(key: key);

  @override
  State<LoanDetailScreen> createState() => _LoanDetailScreenState();
}

class _LoanDetailScreenState extends State<LoanDetailScreen> {
  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF2563EB);
    const Color successGreen = Color(0xFF10B981);
    const Color bgGray = Color(0xFFF3F4F6);

    // Sample installments
    final installments = List.generate(
      widget.tenor,
      (index) => {
        'month': index + 1,
        'date': DateTime.now().add(Duration(days: 30 * (index + 1))).toString().split(' ')[0],
        'amount': widget.amount / widget.tenor,
        'status': index < 3 ? 'PAID' : 'PENDING',
      },
    );

    return Scaffold(
      backgroundColor: bgGray,
      appBar: AppBar(
        title: Text('Detail Pinjaman #${widget.docNumber}'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Loan Info Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Jumlah Pinjaman',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rp ${widget.amount.toStringAsFixed(0).replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.')}',
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 1,
                    color: const Color(0xFFE5E7EB),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.status,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: _getStatusColor(widget.status),
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Tenor',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.tenor} bulan',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Progress Bar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Progress Cicilan',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: 3 / widget.tenor,
                      minHeight: 8,
                      backgroundColor: const Color(0xFFE5E7EB),
                      valueColor: AlwaysStoppedAnimation<Color>(successGreen),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '3 dari ${widget.tenor} cicilan selesai',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Installment Schedule
            Text(
              'Jadwal Cicilan',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 18,
                  ),
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: installments.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final installment = installments[index];
                final isPaid = installment['status'] == 'PAID';
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isPaid
                          ? successGreen.withOpacity(0.2)
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isPaid
                              ? successGreen.withOpacity(0.1)
                              : const Color(0xFFE5E7EB),
                        ),
                        child: Center(
                          child: Text(
                            installment['month'].toString(),
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cicilan ${installment['month']}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              installment['date'].toString(),
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Rp ${(installment['amount'] as double).toStringAsFixed(0).replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.')}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
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
