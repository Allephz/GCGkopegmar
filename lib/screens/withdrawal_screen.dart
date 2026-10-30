// lib/screens/withdrawal_screen.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class WithdrawalScreen extends StatefulWidget {
  const WithdrawalScreen({Key? key}) : super(key: key);

  @override
  State<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends State<WithdrawalScreen> {
  final _apiService = ApiService();
  String? _selectedSavingsType;
  final _amountController = TextEditingController();
  bool _agreedToTerms = false;

  final List<String> savingsTypes = [
    'Simpanan Sukarela',
    'Simpanan Khusus',
  ];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _submitWithdrawal() {
    if (_selectedSavingsType == null ||
        _amountController.text.isEmpty ||
        !_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi semua field terlebih dahulu')),
      );
      return;
    }

    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Penarikan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tipe: $_selectedSavingsType'),
            const SizedBox(height: 8),
            Text('Nominal: Rp ${_amountController.text}'),
            const SizedBox(height: 8),
            const Text('Pastikan data sudah benar?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processWithdrawal();
            },
            child: const Text('Lanjutkan'),
          ),
        ],
      ),
    );
  }

  Future<void> _processWithdrawal() async {
    // Show a loading indicator dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final userId = _apiService.memberId ?? 'CANDRA';
      final double amount = double.tryParse(_amountController.text) ?? 0.0;
      final type = _selectedSavingsType == 'Simpanan Sukarela' ? 'SS' : 'SK';

      final response = await _apiService.requestWithdrawal(
        memberId: userId,
        amount: amount,
        savingsType: type,
        availableBalance: 999999999, // default safe balance threshold
        notes: 'Penarikan $type oleh $userId',
      );

      // Close the loading dialog
      Navigator.pop(context);

      if (response.code == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Penarikan berhasil diajukan. No Dokumen: ${response.docNumber}')),
        );
        // Pop the screen back to home
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengajukan penarikan: ${response.message}')),
        );
      }
    } catch (e) {
      // Close the loading dialog
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString().replaceFirst('Exception: ', '')}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF2563EB);
    const Color successGreen = Color(0xFF10B981);
    const Color bgGray = Color(0xFFF3F4F6);

    return Scaffold(
      backgroundColor: bgGray,
      appBar: AppBar(
        title: const Text('Tarik Simpanan'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step 1: Select Savings Type
            Text(
              'Pilih Tipe Simpanan',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 18,
                  ),
            ),
            const SizedBox(height: 12),
            ...savingsTypes.map((type) {
              final isSelected = _selectedSavingsType == type;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedSavingsType = type;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            isSelected ? primaryBlue : const Color(0xFFE5E7EB),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? primaryBlue
                                  : const Color(0xFFD1D5DB),
                            ),
                          ),
                          child: isSelected
                              ? Container(
                                  margin: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: primaryBlue,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                type,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Saldo: Rp 5.000.000',
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),

            const SizedBox(height: 24),

            // Step 2: Input Amount
            Text(
              'Jumlah Penarikan',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Rp 0',
                prefixText: 'Rp ',
              ),
            ),

            const SizedBox(height: 16),

            // Fee Info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFF59E0B),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rincian Biaya',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: const Color(0xFFF59E0B),
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Nominal Tarik',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.black54,
                            ),
                      ),
                      Text(
                        'Rp ${_amountController.text.isNotEmpty ? _amountController.text : '0'}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Biaya Admin',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.black54,
                            ),
                      ),
                      Text(
                        'Rp 50.000',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Dana Diterima',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      Text(
                        _amountController.text.isNotEmpty
                            ? 'Rp ${(int.parse(_amountController.text.isEmpty ? '0' : _amountController.text) - 50000).toString()}'
                            : 'Rp 0',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Checkbox Agreement
            Row(
              children: [
                Checkbox(
                  value: _agreedToTerms,
                  onChanged: (value) {
                    setState(() {
                      _agreedToTerms = value ?? false;
                    });
                  },
                  activeColor: primaryBlue,
                ),
                Expanded(
                  child: Text(
                    'Saya setuju dengan syarat dan ketentuan penarikan',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _submitWithdrawal,
                child: const Text('Ajukan Penarikan'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
