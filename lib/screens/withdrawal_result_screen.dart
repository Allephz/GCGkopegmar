// lib/screens/withdrawal_result_screen.dart
import 'package:flutter/material.dart';

class WithdrawalResultScreen extends StatelessWidget {
  final bool isSuccess;
  final String docNumber;
  final double amount;

  const WithdrawalResultScreen({
    Key? key,
    this.isSuccess = true,
    this.docNumber = '2025010001',
    this.amount = 5000000,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color successGreen = Color(0xFF10B981);
    const Color errorRed = Color(0xFFEF4444);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Result Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSuccess
                        ? successGreen.withOpacity(0.1)
                        : errorRed.withOpacity(0.1),
                  ),
                  child: Icon(
                    isSuccess ? Icons.check_circle : Icons.error,
                    size: 60,
                    color: isSuccess ? successGreen : errorRed,
                  ),
                ),
                const SizedBox(height: 24),

                // Status Text
                Text(
                  isSuccess ? 'Penarikan Berhasil!' : 'Penarikan Gagal',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 24,
                        color: isSuccess ? successGreen : errorRed,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                Text(
                  isSuccess
                      ? 'Pengajuan penarikan Anda telah berhasil diproses'
                      : 'Terjadi kesalahan dalam memproses pengajuan Anda',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Result Card
                if (isSuccess)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: successGreen.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: successGreen.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _resultItem(context, 'Nomor Dokumen', docNumber),
                        const SizedBox(height: 12),
                        _resultItem(
                          context,
                          'Nominal Penarikan',
                          'Rp ${amount.toStringAsFixed(0).replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.')}',
                        ),
                        const SizedBox(height: 12),
                        _resultItem(
                          context,
                          'Biaya Admin',
                          'Rp 50.000',
                        ),
                        const Divider(height: 16),
                        _resultItem(
                          context,
                          'Dana Diterima',
                          'Rp ${(amount - 50000).toStringAsFixed(0).replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.')}',
                          isBold: true,
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 32),

                // Action Buttons
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Kembali ke Beranda'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      // Navigate to history
                    },
                    child: const Text('Lihat Riwayat'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _resultItem(
    BuildContext context,
    String label,
    String value, {
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.black54,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              ),
        ),
      ],
    );
  }
}
